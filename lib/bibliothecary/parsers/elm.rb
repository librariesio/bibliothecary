require 'json'

module Bibliothecary
  module Parsers
    class Elm
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^elm-package\.json$|^elm_dependencies\.json$/)
          file_contents = File.open(path).read
          parse_json_manifest(file_contents)
        elsif filename.match(/^elm-stuff\/exact-dependencies\.json$/)
          file_contents = File.open(path).read
          parse_json_lock(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^elm-package\.json$|^elm_dependencies\.json$/) ||
          filename.match(/^elm-stuff\/exact-dependencies\.json$/)
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
