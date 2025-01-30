# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Cargo
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("Cargo.toml") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
          match_filename("Cargo.lock") => {
            kind: "lockfile",
            parser: :parse_lockfile,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_manifest(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)

        parsed_dependencies = []

        manifest.fetch_values("dependencies", "dev-dependencies").each_with_index do |deps, index|
          parsed_dependencies << deps.map do |name, requirement|
            if requirement.respond_to?(:fetch)
              requirement = requirement["version"] or next
            end

            Dependency.new(
              name: name,
              requirement: requirement,
              type: index.zero? ? "runtime" : "development",
              source: options.fetch(:filename, nil)
            )
          end
        end

        parsed_dependencies.flatten.compact
      end

      def self.parse_lockfile(file_contents, options: {})
        manifest = Tomlrb.parse(file_contents)
        manifest.fetch("package", []).map do |dependency|
          next if !(dependency["source"]) || !dependency["source"].start_with?("registry+")

          Dependency.new(
            name: dependency["name"],
            requirement: dependency["version"],
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end
          .compact
      end
    end
  end
end
