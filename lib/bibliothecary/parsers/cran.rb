# frozen_string_literal: true

require "deb_control"

module Bibliothecary
  module Parsers
    class CRAN
      include Bibliothecary::Analyser

      REQUIRE_REGEXP = /([a-zA-Z0-9\-_\.]+)\s?\(?([><=\s\d\.,]+)?\)?/

      def self.mapping
        {
          match_filename("DESCRIPTION", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_description,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_description(file_contents, options: {})
        manifest = DebControl::ControlFileBase.parse(file_contents)
        dependencies = parse_section(manifest, "Depends", options.fetch(:filename, nil)) +
                       parse_section(manifest, "Imports", options.fetch(:filename, nil)) +
                       parse_section(manifest, "Suggests", options.fetch(:filename, nil)) +
                       parse_section(manifest, "Enhances", options.fetch(:filename, nil))
        DependenciesResult.new(dependencies: dependencies)
      end

      def self.parse_section(manifest, name, source = nil)
        return [] unless manifest.first[name]

        deps = manifest.first[name].delete("\n").split(",").map(&:strip)
        deps.map do |dependency|
          dep = dependency.match(REQUIRE_REGEXP)
          Dependency.new(
            name: dep[1],
            requirement: dep[2],
            type: name.downcase,
            source: source,
            platform: platform_name
          )
        end
      end
    end
  end
end
