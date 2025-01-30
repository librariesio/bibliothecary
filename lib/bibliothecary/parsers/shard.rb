require "yaml"

module Bibliothecary
  module Parsers
    class Shard
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("shard.yml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_yaml_manifest,
          },
          match_filename("shard.lock", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_yaml_lockfile,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_yaml_lockfile(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = YAML.load file_contents
        map_dependencies(manifest, "shards", "runtime", options.fetch(:filename, nil))
      end

      def self.parse_yaml_manifest(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = YAML.load file_contents
        map_dependencies(manifest, "dependencies", "runtime", options.fetch(:filename, nil)) +
        map_dependencies(manifest, "development_dependencies", "runtime", options.fetch(:filename, nil))
      end

      def self.map_dependencies(hash, key, type, source=nil)
        hash.fetch(key,[]).map do |name, requirement|
          Dependency.new(
            name: name,
            requirement: requirement["version"],
            type: type,
            source: source,
          )
        end
      end
    end
  end
end
