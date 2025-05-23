# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Pypi
      include Bibliothecary::Analyser

      INSTALL_REGEXP = /install_requires\s*=\s*\[([\s\S]*?)\]/

      # Capture Group 1 is package.
      # Optional Group 2 is [extras].
      # Capture Group 3 is Version
      REQUIRE_REGEXP = /([a-zA-Z0-9]+[a-zA-Z0-9\-_\.]+)(?:\[.*?\])*([><=\w\.,]+)?/
      REQUIREMENTS_REGEXP = /^#{REQUIRE_REGEXP}/

      MANIFEST_REGEXP = /.*require[^\/]*\.(txt|pip|in)$/
      # TODO: can this be a more specific regexp so it doesn't match something like ".yarn/cache/create-require-npm-1.0.0.zip"?
      PIP_COMPILE_REGEXP = /.*require.*$/

      # Adapted from https://peps.python.org/pep-0508/#names
      PEP_508_NAME_REGEXP = /^([A-Z0-9][A-Z0-9._-]*[A-Z0-9]|[A-Z0-9])/i

      def self.mapping
        {
          match_filenames("requirements-dev.txt", "requirements/dev.txt",
                          "requirements-docs.txt", "requirements/docs.txt",
                          "requirements-test.txt", "requirements/test.txt",
                          "requirements-tools.txt", "requirements/tools.txt") => {
                            kind: "manifest",
                            parser: :parse_requirements_txt,
                          },
          ->(p) { PIP_COMPILE_REGEXP.match(p) } => {
            content_matcher: :pip_compile?,
            kind: "lockfile",
            parser: :parse_requirements_txt,
          },
          ->(p) { MANIFEST_REGEXP.match(p) } => {
            kind: "manifest",
            parser: :parse_requirements_txt,
            can_have_lockfile: false,
          },
          match_filename("requirements.frozen") => { # pattern exists to store frozen deps in requirements.frozen
            parser: :parse_requirements_txt,
            kind: "lockfile",
          },
          match_filename("pip-resolved-dependencies.txt") => { # Inferred from pip
            kind: "lockfile",
            parser: :parse_requirements_txt,
          },
          match_filename("pip-dependency-graph.json") => { # Exported from pipdeptree --json
            kind: "lockfile",
            parser: :parse_dependency_tree_json,
          },
          match_filename("setup.py") => {
            kind: "manifest",
            parser: :parse_setup_py,
            can_have_lockfile: false,
          },
          match_filename("Pipfile") => {
            kind: "manifest",
            parser: :parse_pipfile,
          },
          match_filename("Pipfile.lock") => {
            kind: "lockfile",
            parser: :parse_pipfile_lock,
          },
          match_filename("pyproject.toml") => {
            kind: "manifest",
            parser: :parse_pyproject,
          },
          match_filename("poetry.lock") => {
            kind: "lockfile",
            parser: :parse_poetry_lock,
          },
          # Pip dependencies can be embedded in conda environment files
          match_filename("environment.yml") => {
            parser: :parse_conda,
            kind: "manifest",
          },
          match_filename("environment.yaml") => {
            parser: :parse_conda,
            kind: "manifest",
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_pipfile(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)
        map_dependencies(manifest["packages"], "runtime", options.fetch(:filename, nil)) +
          map_dependencies(manifest["dev-packages"], "develop", options.fetch(:filename, nil))
      end

      def self.parse_pyproject(file_contents, options: {})
        deps = []

        file_contents = Tomlrb.parse(file_contents)

        # Parse poetry [tool.poetry] deps
        poetry_manifest = file_contents.fetch("tool", {}).fetch("poetry", {})
        deps += map_dependencies(poetry_manifest["dependencies"], "runtime", options.fetch(:filename, nil), normalize_name: true)
        # Poetry 1.0.0-1.2.0 way of defining dev deps
        deps += map_dependencies(poetry_manifest["dev-dependencies"], "develop", options.fetch(:filename, nil), normalize_name: true)
        # Poetry's 1.2.0+ of defining dev deps
        poetry_manifest
          .fetch("group", {})
          .each_pair do |group_name, obj|
            group_name = "develop" if group_name == "dev"
            deps += map_dependencies(obj.fetch("dependencies", {}), group_name, options.fetch(:filename, nil), normalize_name: true)
          end

        # Parse PEP621 [project] deps
        pep621_manifest = file_contents.fetch("project", {})
        pep621_deps = pep621_manifest.fetch("dependencies", []).map { |d| parse_pep_508_dep_spec(d) }
        deps += map_dependencies(pep621_deps, "runtime", options.fetch(:filename, nil), normalize_name: true)

        # We're combining both poetry+PEP621 deps instead of making them mutually exclusive, until we
        # find a reason not to ingest them both.
        deps.uniq
      end

      def self.parse_conda(file_contents, options: {})
        contents = YAML.safe_load(file_contents)
        return [] unless contents

        dependencies = contents["dependencies"]
        pip = dependencies.find { |dep| dep.is_a?(Hash) && dep["pip"] }
        return [] unless pip

        Pypi.parse_requirements_txt(pip["pip"].join("\n"), options:)
      end

      def self.map_dependencies(packages, type, source = nil, normalize_name: false)
        return [] unless packages

        packages.flat_map do |name, package_info|
          local = true if package_info.is_a?(Hash) && (package_info.key?("path") || package_info.key?("file"))

          if package_info.is_a?(Array)
            # Poetry supports multiple requirements with differing specifiers for the same
            # package. Break these out into a separate dep per requirement.
            # https://python-poetry.org/docs/dependency-specification/#multiple-constraints-dependencies
            package_info.map do |info|
              # Poetry normalizes names in lockfiles but doesn't provide the original, so we need to keep
              # track of the original name so the dep is connected between manifest+lockfile.
              normalized_name = normalize_name(name)
              Dependency.new(
                name: normalize_name ? normalized_name : name,
                original_name: normalize_name && name != normalized_name ? name : nil,
                requirement: map_requirements(info),
                type: type,
                source: source,
                local: local
              )
            end
          else
            # Poetry normalizes names in lockfiles but doesn't provide the original, so we need to keep
            # track of the original name so the dep is connected between manifest+lockfile.
            normalized_name = normalize_name(name)
            Dependency.new(
              name: normalize_name ? normalized_name : name,
              original_name: normalize_name && name != normalized_name ? name : nil,
              requirement: map_requirements(package_info),
              type: type,
              source: source,
              local: local
            )
          end
        end
      end

      def self.map_requirements(info)
        if info.is_a?(Hash)
          if info["version"]
            info["version"]
          elsif info["git"]
            "#{info['git']}##{info['ref'] || info['tag']}"
          else
            "*"
          end
        else
          info
        end
      end

      def self.parse_pipfile_lock(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        deps = []
        manifest.each do |group, dependencies|
          next if group == "_meta"

          group = "runtime" if group == "default"
          deps += map_dependencies(dependencies, group, options.fetch(:filename, nil))
        end
        deps
      end

      def self.parse_poetry_lock(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)
        deps = []
        manifest["package"].each do |package|
          # next if group == "_meta"

          # Poetry <1.2.0 used singular "category" for kind
          # Poetry >=1.2.0 uses plural "groups" field for kind(s)
          groups = package.values_at("category", "groups").flatten.compact
            .map do |g|
              if g == "dev"
                "develop"
              else
                (g == "main" ? "runtime" : g)
              end
            end

          groups = ["runtime"] if groups.empty?

          groups.each do |group|
            # Poetry lockfiles should already contain normalizated names, but we'll
            # apply it here as well just to be consistent with pyproject.toml parsing.
            normalized_name = normalize_name(package["name"])
            deps << Dependency.new(
              name: normalized_name,
              original_name: normalized_name == package["name"] ? nil : package["name"],
              requirement: map_requirements(package),
              type: group,
              source: options.fetch(:filename, nil)
            )
          end
        end
        deps
      end

      def self.parse_setup_py(file_contents, options: {})
        match = file_contents.match(INSTALL_REGEXP)
        return [] unless match

        deps = []
        match[1].gsub(/',(\s)?'/, "\n").split("\n").each do |line|
          next if line.match(/^#/)

          match = line.match(REQUIRE_REGEXP)
          next unless match

          deps << Dependency.new(
            name: match[1],
            requirement: match[-1],
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end
        deps
      end

      # While the thing in the repo that PyPI is using might be either in
      # egg format or wheel format, PyPI uses "egg" in the fragment of the
      # VCS URL to specify what package in the PyPI index the VCS URL
      # should be treated as.
      NoEggSpecified = Class.new(ArgumentError)

      def self.parse_dependency_tree_json(file_contents, options: {})
        JSON.parse(file_contents)
          .map do |pkg|
            Dependency.new(
              name: pkg.dig("package", "package_name"),
              requirement: pkg.dig("package", "installed_version"),
              type: "runtime",
              source: options.fetch(:filename, nil)
            )
          end
          .uniq
      end

      # Parses a requirements.txt file, following the
      # https://pip.pypa.io/en/stable/cli/pip_install/#requirement-specifiers
      # and https://pip.pypa.io/en/stable/topics/vcs-support/#git.
      # Invalid lines in requirements.txt are skipped.
      def self.parse_requirements_txt(file_contents, options: {})
        deps = []
        type = case options[:filename]
               when /dev/ || /docs/ || /tools/
                 "development"
               when /test/
                 "test"
               else
                 "runtime"
               end

        file_contents.split("\n").each do |line|
          if line["://"]
            begin
              result = parse_requirements_txt_url(line, type, options.fetch(:filename, nil))
            rescue URI::Error, NoEggSpecified
              next
            end

            deps << result
          elsif (match = line.delete(" ").match(REQUIREMENTS_REGEXP))
            deps << Dependency.new(
              name: match[1],
              requirement: match[-1],
              type: type,
              source: options.fetch(:filename, nil)
            )
          end
        end

        deps.uniq
      end

      def self.parse_requirements_txt_url(url, type = nil, source = nil)
        uri = URI.parse(url)
        raise NoEggSpecified, "No egg specified in #{url}" unless uri.fragment

        name = uri.fragment[/^egg=([^&]+)([&]|$)/, 1]
        raise NoEggSpecified, "No egg specified in #{url}" unless name

        requirement = uri.path[/@(.+)$/, 1]

        Dependency.new(
          name: name,
          requirement: requirement,
          type: type,
          source: source
        )
      end

      def self.pip_compile?(file_contents)
        file_contents.include?("This file is autogenerated by pip-compile")
      rescue Exception # rubocop:disable Lint/RescueException
        # We rescue exception here since native libs can throw a non-StandardError
        # We don't want to throw errors during the matching phase, only during
        # parsing after we match.
        false
      end

      # Simply parses out the name of a PEP 508 Dependency specification: https://peps.python.org/pep-0508/
      # Leaves the rest as-is with any leading semicolons or spaces stripped
      def self.parse_pep_508_dep_spec(dep)
        name, requirement = dep.split(PEP_508_NAME_REGEXP, 2).last(2).map(&:strip)
        requirement = requirement.sub(/^[\s;]*/, "")
        requirement = "*" if requirement == ""
        [name, requirement]
      end

      # Apply PyPa's name normalization rules to the package name
      # https://packaging.python.org/en/latest/specifications/name-normalization/#name-normalization
      def self.normalize_name(name)
        name.downcase.gsub(/[-_.]+/, "-")
      end
    end
  end
end
