require 'json'

module Bibliothecary
  module Parsers
    class Meteor
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^versions\.json$/)
          file_contents = File.open(path).read
          parse_manifest(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^versions\.json$/)
      end

      def self.parse_manifest(file_contents)
        manifest = JSON.parse(file_contents)
        map_dependencies(manifest, 'dependencies', 'runtime')
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
