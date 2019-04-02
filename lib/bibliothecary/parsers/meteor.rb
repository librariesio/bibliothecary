require 'json'

module Bibliothecary
  module Parsers
    class Meteor
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("versions.json") => {
            kind: 'manifest',
            parser: :parse_json_runtime_manifest
          }
        }
      end
    end
  end
end
