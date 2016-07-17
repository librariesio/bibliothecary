require 'json'

module Bibliothecary
  module Parsers
    class Packagist
      include Bibliothecary::Analyser

      def self.parse(filename, file_contents)
        if filename.match(/^composer\.json$/)
          json = JSON.parse(file_contents)
          parse_manifest(json)
        elsif filename.match(/^composer\.lock$/)
          json = JSON.parse(file_contents)
          parse_lockfile(json)
        else
          []
        end
      end

      def self.parse_lockfile(manifest)
        manifest.fetch('packages',[]).map do |dependency|
          {
            name: dependency["name"],
            requirement: dependency["version"],
            type: 'runtime'
          }
        end
      end

      def self.parse_manifest(manifest)
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
