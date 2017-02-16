require 'json'

module Bibliothecary
  module Parsers
    class Elm
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^elm-package\.json$|^elm_dependencies\.json$/ => :parse_json_manifest,
          /^elm-stuff\/exact-dependencies\.json$/ => :parse_json_lock
        }
      end

      def self.parse_json_manifest(file_contents)
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'dependencies', 'runtime')
      end

      def self.parse_json_lock(file_contents)
        manifest = JSON.parse file_contents
        manifest.map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
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
