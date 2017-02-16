require 'json'

module Bibliothecary
  module Parsers
    class Packagist
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^composer\.json$/)
          file_contents = File.open(path).read
          parse_manifest(file_contents)
        elsif filename.match(/^composer\.lock$/)
          file_contents = File.open(path).read
          parse_lockfile(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^composer\.json$/) || filename.match(/^composer\.lock$/)
      end

      def self.parse_lockfile(file_contents)
        manifest = JSON.parse file_contents
        manifest.fetch('packages',[]).map do |dependency|
          {
            name: dependency["name"],
            requirement: dependency["version"],
            type: 'runtime'
          }
        end
      end

      def self.parse_manifest(file_contents)
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'require', 'runtime') +
        map_dependencies(manifest, 'require-dev', 'development')
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
