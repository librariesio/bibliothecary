# frozen_string_literal: true

require "yaml"
require "json"

module Bibliothecary
  module Parsers
    class CPAN
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("META.json", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_json_manifest,
          },
          match_filename("META.yml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_yaml_manifest,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_json_manifest(file_contents, options: {})
        manifest = JSON.parse file_contents
        dependencies = manifest["prereqs"].map do |_group, deps|
          map_dependencies(deps, "requires", "runtime", options.fetch(:filename, nil))
        end.flatten
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_yaml_manifest(file_contents, options: {})
        manifest = YAML.load file_contents
        dependencies = map_dependencies(manifest, "requires", "runtime", options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
