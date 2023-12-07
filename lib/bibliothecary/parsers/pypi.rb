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
      MANIFEST_REGEXP = /.*require[^\/]*(\/)?[^\/]*\.(txt|pip|in)$/
      PIP_COMPILE_REGEXP = /.*require.*$/

      # Adapted from https://peps.python.org/pep-0508/#names
      PEP_508_NAME_REGEX = /^([A-Z0-9][A-Z0-9._-]*[A-Z0-9]|[A-Z0-9])/i

      def self.mapping
        {
          match_filenames('requirements-dev.txt', 'requirements/dev.txt',
                          'requirements-docs.txt', 'requirements/docs.txt',
                          'requirements-test.txt', 'requirements/test.txt',
                          'requirements-tools.txt', 'requirements/tools.txt') => {
            kind: 'manifest',
            parser: :parse_requirements_txt
          },
          lambda { |p| PIP_COMPILE_REGEXP.match(p) } => {
            content_matcher: :pip_compile?,
            kind: 'lockfile',
            parser: :parse_requirements_txt
          },
          lambda { |p| MANIFEST_REGEXP.match(p) } => {
            kind: 'manifest',
            parser: :parse_requirements_txt,
            can_have_lockfile: false
          },
          match_filename('requirements.frozen') => { # pattern exists to store frozen deps in requirements.frozen
            parser: :parse_requirements_txt,
            kind: 'lockfile'
          },
          match_filename('pip-resolved-dependencies.txt') => { # Inferred from pip
            kind: 'lockfile',
            parser: :parse_requirements_txt
          },
          match_filename("setup.py") => {
            kind: 'manifest',
            parser: :parse_setup_py,
            can_have_lockfile: false
          },
          match_filename("Pipfile") => {
            kind: 'manifest',
            parser: :parse_pipfile
          },
          match_filename("Pipfile.lock") => {
            kind: 'lockfile',
            parser: :parse_pipfile_lock
          },
          match_filename("pyproject.toml") => {
            kind: 'manifest',
            parser: :parse_pyproject
          },
          match_filename("poetry.lock") => {
            kind: 'lockfile',
            parser: :parse_poetry_lock
          },
          # Pip dependencies can be embedded in conda environment files
          match_filename("environment.yml") => {
            parser: :parse_conda,
            kind: "manifest"
          },
          match_filename("environment.yaml") => {
            parser: :parse_conda,
            kind: "manifest"
          },
          match_filename("environment.yml.lock") => {
            parser: :parse_conda,
            kind: "lockfile"
          },
          match_filename("environment.yaml.lock") => {
            parser: :parse_conda,
            kind: "lockfile"
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_pipfile(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)
        map_dependencies(manifest['packages'], 'runtime') + map_dependencies(manifest['dev-packages'], 'develop')
      end

      def self.parse_pyproject(file_contents, options: {})
        deps = []

        file_contents = Tomlrb.parse(file_contents)

        # Parse poetry [tool.poetry] deps
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # Parse poetry [tool.poetry.group.docs] deps
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {}).fetch('group', {}).fetch('docs', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # Parse poetry [tool.poetry.group.lint] deps
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {}).fetch('group', {}).fetch('lint', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # Parse poetry [tool.poetry.group.codespell] deps
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {}).fetch('group', {}).fetch('codespell', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # [tool.poetry.group.dev.dependencies]
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {}).fetch('group', {}).fetch('dev', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # [tool.poetry.group.test.dependencies]
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {}).fetch('group', {}).fetch('test', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # [tool.poetry.group.typing.dependencies]
        poetry_manifest = file_contents.fetch('tool', {}).fetch('poetry', {}).fetch('group', {}).fetch('typing', {})
        deps += map_dependencies(poetry_manifest['dependencies'], 'runtime')
        deps += map_dependencies(poetry_manifest['dev-dependencies'], 'develop')

        # Parse PEP621 [project] deps
        pep621_manifest = file_contents.fetch('project', {})
        pep621_deps = pep621_manifest.fetch('dependencies', []).map { |d| parse_pep_508_dep_spec(d) }
        deps += map_dependencies(pep621_deps, 'runtime')

        # We're combining both poetry+PEP621 deps instead of making them mutually exclusive, until we
        # find a reason not to ingest them both.
        deps.uniq
      end

      # TODO: this was deprecated in 8.6.0. Remove this in any major version bump >= 9.*
      def self.parse_poetry(file_contents, options: {})
        puts "Warning: parse_poetry() is deprecated, use parse_pyproject() instead."
        parse_pyproject(file_contents, options)
      end

      def self.parse_conda(file_contents, options: {})
        contents = YAML.safe_load(file_contents)
        return [] unless contents

        dependencies = contents["dependencies"]
        pip = dependencies.find { |dep| dep.is_a?(Hash) && dep["pip"]}
        return [] unless pip

        Pypi.parse_requirements_txt(pip["pip"].join("\n"))
      end

      def self.map_dependencies(packages, type)
        return [] unless packages
        packages.map do |name, info|
          {
            name: name,
            requirement: map_requirements(info),
            type: type
          }
        end
      end

      def self.map_requirements(info)
        if info.is_a?(Hash)
          if info['version']
            info['version']
          elsif info['git']
            info['git'] + '#' + info['ref']
          else
            '*'
          end
        else
          info || '*'
        end
      end

      def self.parse_pipfile_lock(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        deps = []
        manifest.each do |group, dependencies|
          next if group == "_meta"
          group = 'runtime' if group == 'default'
          dependencies.each do |name, info|
            deps << {
              name: name,
              requirement: map_requirements(info),
              type: group
            }
          end
        end
        deps
      end

      def self.parse_poetry_lock(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)
        deps = []
        manifest["package"].each do |package|
          # next if group == "_meta"
          group = case package['category']
                  when 'main'
                    'runtime'
                  when 'dev'
                    'develop'
                  end

          deps << {
            name: package['name'],
            requirement: map_requirements(package),
            type: group
          }
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
          deps << {
            name: match[1],
            requirement: match[-1] || '*',
            type: 'runtime'
          }
        end
        deps
      end

      # While the thing in the repo that PyPI is using might be either in
      # egg format or wheel format, PyPI uses "egg" in the fragment of the
      # VCS URL to specify what package in the PyPI index the VCS URL
      # should be treated as.
      NoEggSpecified = Class.new(ArgumentError)

      # Parses a requirements.txt file, following the
      # https://pip.pypa.io/en/stable/cli/pip_install/#requirement-specifiers
      # and https://pip.pypa.io/en/stable/topics/vcs-support/#git.
      # Invalid lines in requirements.txt are skipped.
      def self.parse_requirements_txt(file_contents, options: {})
        deps = []
        type = case options[:filename]
               when /dev/ || /docs/ || /tools/
                 'development'
               when /test/
                 'test'
               else
                 'runtime'
               end

        file_contents.split("\n").each do |line|
          if line['://']
            begin
              result = parse_requirements_txt_url(line)
            rescue URI::Error, NoEggSpecified => e
              next
            end

            deps << result.merge(
              type: type
            )
          else
            match = line.delete(' ').match(REQUIREMENTS_REGEXP)
            next unless match

            deps << {
              name: match[1],
              requirement: match[-1] || '*',
              type: type
            }
          end
        end
        deps
      end

      def self.parse_requirements_txt_url(url)
        uri = URI.parse(url)
        raise NoEggSpecified, "No egg specified in #{url}" unless uri.fragment

        name = uri.fragment[/^egg=([^&]+)([&]|$)/, 1]
        raise NoEggSpecified, "No egg specified in #{url}" unless name

        requirement = uri.path[/@(.+)$/, 1]

        { name: name, requirement: requirement || "*" }
      end

      def self.pip_compile?(file_contents)
        return file_contents.include?("This file is autogenerated by pip-compile")
      rescue Exception # rubocop:disable Lint/RescueException
        # We rescue exception here since native libs can throw a non-StandardError
        # We don't want to throw errors during the matching phase, only during
        # parsing after we match.
        false
      end

      # Simply parses out the name of a PEP 508 Dependency specification: https://peps.python.org/pep-0508/
      # Leaves the rest as-is with any leading semicolons or spaces stripped
      def self.parse_pep_508_dep_spec(dep)
        name, requirement = dep.split(PEP_508_NAME_REGEX, 2).last(2).map(&:strip)
        requirement = requirement.sub(/^[\s;]*/, "")
        requirement = "*" if requirement == ""
        return name, requirement
      end
    end
  end
end
