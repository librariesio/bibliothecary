require 'json'

module Bibliothecary
  module Parsers
    class Bower
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^bower\.json$/)
          file_contents = File.open(path).read
          parse_manifest(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^bower\.json$/)
      end

      def self.parse_manifest(manifest)
        json = JSON.parse(manifest)
        map_dependencies(json, 'dependencies', 'runtime') +
        map_dependencies(json, 'devDependencies', 'development')
      end

      def self.map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: type
          }
        end
      end
    end
  end
end
