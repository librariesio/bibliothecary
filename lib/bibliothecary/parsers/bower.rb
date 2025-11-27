# frozen_string_literal: true

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

      def self.parse_manifest(file_contents, options: {})
        json = JSON.parse(file_contents)
        dependencies = map_dependencies(json, "dependencies", "runtime", options.fetch(:filename, nil)) +
                       map_dependencies(json, "devDependencies", "development", options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
