require 'json'
require 'sdl_parser'

module Bibliothecary
  module Parsers
    class Dub
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^dub\.json$/ => :parse_manifest,
          /^dub\.sdl$/ => :parse_sdl_manifest
        }
      end

      def self.parse_manifest(file_contents)
        manifest = JSON.parse(file_contents)
        map_dependencies(manifest, 'dependencies', 'runtime')
      end

      def self.parse_sdl_manifest(manifest)
        SdlParser.new(:runtime, manifest).dependencies
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
