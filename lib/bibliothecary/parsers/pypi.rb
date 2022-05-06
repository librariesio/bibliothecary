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

      def self.mapping
        {
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
            kind: 'lockfile',
          },
          match_filename('pip-resolved-dependencies.txt') => { # Inferred from pip
            kind: 'lockfile',
            parser: :parse_requirements_txt,
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
            parser: :parse_poetry
          },
          match_filename("poetry.lock") => {
            kind: 'lockfile',
            parser: :parse_poetry_lock
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
          match_filename("environment.yml.lock") => {
            parser: :parse_conda,
            kind: "lockfile",
          },
          match_filename("environment.yaml.lock") => {
            parser: :parse_conda,
            kind: "lockfile",
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_pipfile(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)
        map_dependencies(manifest['packages'], 'runtime') + map_dependencies(manifest['dev-packages'], 'develop')
      end

      def self.parse_poetry(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)['tool']['poetry']
        map_dependencies(manifest['dependencies'], 'runtime') + map_dependencies(manifest['dev-dependencies'], 'develop')
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

      NoEggSpecified = Class.new(ArgumentError)

      # Parses a requirements.txt file, following the
      # https://pip.pypa.io/en/stable/cli/pip_install/#requirement-specifiers
      # and https://pip.pypa.io/en/stable/topics/vcs-support/#git.
      # Invalid lines in requirements.txt are skipped.
      def self.parse_requirements_txt(file_contents, options: {})
        deps = []
        file_contents.split("\n").each do |line|
          if line['://']
            begin
              result = parse_requirements_txt_url(line)
            rescue URI::Error, NoEggSpecified => e
              next
            end

            deps << result.merge(
              type: 'runtime'
            )
          else
            match = line.delete(' ').match(REQUIREMENTS_REGEXP)
            next unless match

            deps << {
              name: match[1],
              requirement: match[-1] || '*',
              type: 'runtime'
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
    end
  end
end
