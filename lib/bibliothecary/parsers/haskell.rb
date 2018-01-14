require "json"

module Bibliothecary
  module Parsers
    class Haskell
      include Bibliothecary::Analyser

      def self.mapping
        {
          /.*\.cabal$/ => {
            kind: 'lockfile',
            parser: :parse_cabal
          },
        }
      end

      def self.parse_cabal(file_contents)
        headers = {
          'Content-Type' => "text/plain;charset=utf-8"
        }

        response = Typhoeus.post("https://cabal-parser.libraries.io/parse", headers: headers, body: file_contents)
        
        if response.response_code == 200 then
          JSON.parse(response.body, symbolize_names: true)
        else
          []
        end
      end
    end
  end
end
