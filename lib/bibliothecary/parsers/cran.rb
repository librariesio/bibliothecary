require 'deb_control'

module Bibliothecary
  module Parsers
    class CRAN
      include Bibliothecary::Analyser

      REQUIRE_REGEXP = /([a-zA-Z0-9\-_\.]+)\s?\(?([><=\s\d\.,]+)?\)?/

      def self.mapping
        {
          match_filename("DESCRIPTION", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_description
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_description(file_contents, options: {})
        manifest = DebControl::ControlFileBase.parse(file_contents)
        parse_section(manifest, 'Depends') +
        parse_section(manifest, 'Imports') +
        parse_section(manifest, 'Suggests') +
        parse_section(manifest, 'Enhances')
      end

      def self.parse_section(manifest, name)
        return [] unless manifest.first[name]
        deps = manifest.first[name].delete("\n").split(',').map(&:strip)
        deps.map do |dependency|
          dep = dependency.match(REQUIRE_REGEXP)
          {
            name: dep[1],
            requirement: dep[2] || '*',
            type: name.downcase
          }
        end
      end
    end
  end
end
