require "json"

module Bibliothecary
  module Parsers
    class Bower
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("bower.json") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_manifest(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        json = JSON.parse(file_contents)
        map_dependencies(json, "dependencies", "runtime", options.fetch(:filename, nil)) +
        map_dependencies(json, "devDependencies", "development", options.fetch(:filename, nil))
      end
    end
  end
end
