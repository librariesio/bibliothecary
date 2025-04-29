# frozen_string_literal: true

require "yaml"

module Bibliothecary
  module Parsers
    class Pub
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("pubspec.yaml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_yaml_manifest,
          },
          match_filename("pubspec.lock", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_yaml_lockfile,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_yaml_manifest(file_contents, options: {})
        manifest = YAML.load file_contents
        map_dependencies(manifest, "dependencies", "runtime", options.fetch(:filename, nil)) +
          map_dependencies(manifest, "dev_dependencies", "development", options.fetch(:filename, nil))
      end

      def self.parse_yaml_lockfile(file_contents, options: {})
        manifest = YAML.load file_contents
        manifest.fetch("packages", []).map do |name, dep|
          Dependency.new(
            name: name,
            requirement: dep["version"],
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end
      end
    end
  end
end
