require 'yaml'

module Bibliothecary
  module Parsers
    class Pub
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^pubspec\.yaml$/i => {
            kind: 'manifest',
            parser: :parse_yaml_manifest
          },
          /^pubspec\.lock$/i => {
            kind: 'lockfile',
            parser: :parse_yaml_lockfile
          }
        }
      end

      def self.parse_yaml_manifest(file_contents)
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'dev_dependencies', 'development')
      end

      def self.parse_yaml_lockfile(file_contents)
        manifest = YAML.load file_contents
        manifest.fetch('packages', []).map do |name, dep|
          {
            name: name,
            requirement: dep['version'],
            type: 'runtime'
          }
        end
      end
    end
  end
end
