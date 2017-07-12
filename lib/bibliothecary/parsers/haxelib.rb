require 'json'

module Bibliothecary
  module Parsers
    class Haxelib
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^haxelib\.json$/ => {
            kind: 'manifest',
            parser: :parse_manifest
          }
        }
      end

      def self.parse_manifest(manifest)
        json = JSON.parse(manifest)
        map_dependencies(json, 'dependencies', 'runtime')
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
