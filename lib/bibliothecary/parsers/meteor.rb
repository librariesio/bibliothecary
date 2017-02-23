require 'json'

module Bibliothecary
  module Parsers
    class Meteor
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^versions\.json$/ => {
            kind: 'manifest',
            parser: :parse_manifest
          }
        }
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
