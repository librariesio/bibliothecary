module Bibliothecary
  module Parsers
    class Pypi
      include Bibliothecary::Analyser

      INSTALL_REGEXP = /install_requires\s*=\s*\[([\s\S]*?)\]/
      REQUIRE_REGEXP = /([a-zA-Z0-9]+[a-zA-Z0-9\-_\.]+)([><=\d\.,]+)?/
      REQUIREMENTS_REGEXP = /^#{REQUIRE_REGEXP}/

      def self.parse(filename, file_contents)
        is_valid_requirements_file = is_requirements_file(filename)
        if is_valid_requirements_file
          parse_requirements_txt(file_contents)
        elsif filename.match(/setup\.py$/)
          parse_setup_py(file_contents)
        else
          []
        end
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
          match = line.match(REQUIREMENTS_REGEXP)
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
        is_requirements_file = filename.match(/require.*\.(txt|pip)$/)
        if filename.match(/require.*\.(txt|pip)$/) and !filename.match(/^node_modules/)
          return true
        else
          return false
        end
      end
    end
  end
end
