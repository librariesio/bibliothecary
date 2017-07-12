require 'json'

module Bibliothecary
  module Parsers
    class Packagist
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^composer\.json$/ => {
            kind: 'manifest',
            parser: :parse_manifest
          },
          /^composer\.lock$/ => {
            kind: 'lockfile',
            parser: :parse_lockfile
          }
        }
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
    end
  end
end
