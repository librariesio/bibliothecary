require 'json'
require 'sdl_parser'

module Bibliothecary
  module Parsers
    class Dub
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^dub\.json$/)
          file_contents = File.open(path).read
          json = JSON.parse(file_contents)
          parse_manifest(json)
        elsif filename.match(/^dub\.sdl$/)
          file_contents = File.open(path).read
          parse_sdl_manifest(file_contents)
        else
          []
        end
      end

      def self.parse_manifest(manifest)
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
