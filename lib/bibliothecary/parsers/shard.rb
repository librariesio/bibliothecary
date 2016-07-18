require 'yaml'

module Bibliothecary
  module Parsers
    class Shard
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^shard\.yml$/i)
          file_contents = File.open(path).read
          yaml = YAML.load file_contents
          parse_yaml_manifest(yaml)
        elsif filename.match(/^shard\.lock$/i)
          file_contents = File.open(path).read
          yaml = YAML.load file_contents
          parse_yaml_lockfile(yaml)
        else
          []
        end
      end

      def self.parse_yaml_lockfile(manifest)
        map_dependencies(manifest, 'shards', 'runtime')
      end

      def self.parse_yaml_manifest(manifest)
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
