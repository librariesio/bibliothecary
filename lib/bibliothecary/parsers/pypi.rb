module Bibliothecary
  module Parsers
    class Pypi
      include Bibliothecary::Analyser

      INSTALL_REGEXP = /install_requires\s*=\s*\[([\s\S]*?)\]/
      REQUIRE_REGEXP = /([a-zA-Z0-9]+[a-zA-Z0-9\-_\.]+)([><=\w\.,]+)?/
      REQUIREMENTS_REGEXP = /^#{REQUIRE_REGEXP}/
      MANIFEST_REGEXP = /.*require[^\/]*(\/)?[^\/]*\.(txt|pip)$/

      def self.mapping
        {
          lambda { |p| MANIFEST_REGEXP.match(p) } => {
            kind: 'manifest',
            parser: :parse_requirements_txt,
            can_have_lockfile: false
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
          }
        }
      end

      def self.parse_pipfile(file_contents)
        manifest = TomlRB.parse(file_contents)
        map_dependencies(manifest['packages'], 'runtime') + map_dependencies(manifest['dev-packages'], 'develop')
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

      def self.parse_pipfile_lock(file_contents)
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

      def self.parse_setup_py(manifest)
        match = manifest.match(INSTALL_REGEXP)
        return [] unless match
        deps = []
        match[1].gsub(/',(\s)?'/, "\n").split("\n").each do |line|
          next if line.match(/^#/)
          match = line.match(REQUIRE_REGEXP)
          next unless match
          deps << {
            name: match[1],
            requirement: match[2] || '*',
            type: 'runtime'
          }
        end
        deps
      end

      def self.parse_requirements_txt(manifest)
        deps = []
        manifest.split("\n").each do |line|
          match = line.delete(' ').match(REQUIREMENTS_REGEXP)
          next unless match
          deps << {
            name: match[1],
            requirement: match[2] || '*',
            type: 'runtime'
          }
        end
        deps
      end
    end
  end
end
