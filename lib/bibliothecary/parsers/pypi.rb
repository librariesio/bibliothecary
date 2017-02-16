module Bibliothecary
  module Parsers
    class Pypi
      include Bibliothecary::Analyser

      INSTALL_REGEXP = /install_requires\s*=\s*\[([\s\S]*?)\]/
      REQUIRE_REGEXP = /([a-zA-Z0-9]+[a-zA-Z0-9\-_\.]+)([><=\d\.,]+)?/
      REQUIREMENTS_REGEXP = /^#{REQUIRE_REGEXP}/

      def self.parse(filename, path)
        if is_requirements_file(filename)
          parse_requirements_txt(File.open(path).read)
        elsif filename.match(/setup\.py$/)
          parse_setup_py(File.open(path).read)
        end
      end

      def self.match?(filename)
        is_requirements_file(filename) || filename.match(/setup\.py$/)
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
