require 'yaml'

module Bibliothecary
  module Parsers
    class Shard
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^shard\.yml$|.*\/shard\.yml$/i => {
            kind: 'manifest',
            parser: :parse_yaml_manifest
          },
          /^shard\.lock$|.*\/shard\.lock$/i => {
            kind: 'lockfile',
            parser: :parse_yaml_lockfile
          }
        }
      end

      def self.parse_yaml_lockfile(file_contents)
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'shards', 'runtime')
      end

      def self.parse_yaml_manifest(file_contents)
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'development_dependencies', 'runtime')
      end

      def self.map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement['version'] || '*',
            type: type
          }
        end
      end
    end
  end
end
