require 'json'
require 'sdl_parser'

module Bibliothecary
  module Parsers
    class Dub
      PLATFORM_NAME = 'dub'

      def self.parse(filename, file_contents)
        if filename.match(/^dub\.json$/)
          json = JSON.parse(file_contents)
          parse_manifest(json)
        elsif filename.match(/^dub\.sdl$/)
          parse_sdl_manifest(file_contents)
        else
          []
        end
      end

      def self.analyse_json(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^dub\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_manifest(manifest)
        }
      end

      def self.analyse_sdl(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^dub\.sdl$/) }
        return unless path

        manifest = File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_sdl_manifest(manifest)
        }
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
