require 'json'

module Bibliothecary
  module Parsers
    class Bower
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^bower\.json$/)
          file_contents = File.open(path).read
          json = JSON.parse(file_contents)
          parse_manifest(json)
        else
          []
        end
      end

      def self.parse_manifest(manifest)
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'devDependencies', 'development')
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
