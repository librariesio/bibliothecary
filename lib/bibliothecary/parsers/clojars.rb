require 'json'
require 'typhoeus'

module Bibliothecary
  module Parsers
    class Clojars
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("project.clj") => {
            kind: 'manifest',
            parser: :parse_manifest
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_manifest(file_contents, options: {})
        response = Typhoeus.post("#{Bibliothecary.configuration.clojars_parser_host}/project.clj", body: file_contents, timeout: 60)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.clojars_parser_host}/project.clj", response.response_code) unless response.success?
        json = JSON.parse response.body
        index = json.index("dependencies")

        return [] unless index;
        dependencies = json[index + 1]
        dependencies.map do |dependency|
          {
            name: dependency[0],
            requirement: dependency[1],
            type: "runtime"
          }
        end
      end
    end
  end
end
