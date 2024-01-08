require "json"

module Bibliothecary
  module Parsers
    class Meteor
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::JSONRuntime

      def self.mapping
        {
          match_filename("versions.json") => {
            kind: "manifest",
            parser: :parse_json_runtime_manifest,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
    end
  end
end
