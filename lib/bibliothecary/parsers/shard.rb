require "yaml"

module Bibliothecary
  module Parsers
    class Shard
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("shard.yml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_yaml_manifest
          },
          match_filename("shard.lock", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_yaml_lockfile
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_yaml_lockfile(file_contents, options: {})
        manifest = YAML.load file_contents
        map_dependencies(manifest, "shards", "runtime")
      end

      def self.parse_yaml_manifest(file_contents, options: {})
        manifest = YAML.load file_contents
        map_dependencies(manifest, "dependencies", "runtime") +
        map_dependencies(manifest, "development_dependencies", "runtime")
      end

      def self.map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement["version"] || "*",
            type: type
          }
        end
      end
    end
  end
end
