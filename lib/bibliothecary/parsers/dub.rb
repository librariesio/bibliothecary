require "json"
require "sdl_parser"

module Bibliothecary
  module Parsers
    class Dub
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::JSONRuntime

      def self.mapping
        {
          match_filename("dub.json") => {
            kind: "manifest",
            parser: :parse_json_runtime_manifest,
          },
          match_filename("dub.sdl") => {
            kind: "manifest",
            parser: :parse_sdl_manifest,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_sdl_manifest(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        SdlParser.new(:runtime, file_contents, options.fetch(:filename, nil)).dependencies
      end
    end
  end
end
