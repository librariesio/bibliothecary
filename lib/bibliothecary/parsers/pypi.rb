module Bibliothecary
  module Parsers
    class Pypi
      include Bibliothecary::Analyser

      INSTALL_REGEXP = /install_requires\s*=\s*\[([\s\S]*?)\]/
      REQUIRE_REGEXP = /([a-zA-Z0-9]+[a-zA-Z0-9\-_\.]+)([><=\d\.,]+)?/
      REQUIREMENTS_REGEXP = /^#{REQUIRE_REGEXP}/

      def self.parse_file(filename, contents)
        if is_requirements_file(filename)
          parse_requirements_txt(contents)
        elsif filename.match(/setup\.py$/)
          parse_setup_py(contents)
        elsif filename.match(/^Pipfile$/)
          parse_pipfile(contents)
        elsif filename.match(/^Pipfile\.lock$/)
          parse_pipfile_lock(contents)
        end
      end

      def self.match?(filename)
        is_requirements_file(filename) ||
        filename.match(/setup\.py$/) ||
        filename.match(/Pipfile$/) ||
        filename.match(/Pipfile\.lock$/)
      end

      def self.parse_pipfile(file_contents)
        manifest = TOML.parse(file_contents)
        map_dependencies(manifest['packages'], 'runtime') + map_dependencies(manifest['dev-packages'], 'develop')
      end

      def self.map_dependencies(packages, type)
        return [] unless packages
        packages.map do |name, info|
          if info.is_a?(Hash)
            if info['version']
              requirement = info['version']
            elsif info['git']
              requirement = info['git'] + '#' + info['ref']
            else
              requirement = '*'
            end
          else
            requirement = info || '*'
          end
          {
            name: name,
            requirement: requirement,
            type: type
          }
        end
      end

      def self.parse_pipfile_lock(file_contents)
        manifest = JSON.parse(file_contents)
        deps = []
        manifest.each do |group, dependencies|
          next if group == "_meta"
          group = 'runtime' if group == 'default'
          dependencies.each do |name, info|
            if info['version']
              requirement = info['version']
            elsif info['git']
              requirement = info['git'] + '#' + info['ref']
            else
              requirement = '*'
            end

            deps << {
              name: name,
              requirement: requirement,
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

      def self.is_requirements_file(filename)
        if filename.match(/require.*\.(txt|pip)$/) and !filename.match(/^node_modules/)
          return true
        else
          return false
        end
      end
    end
  end
end
