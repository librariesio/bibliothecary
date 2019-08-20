require 'json'
require 'stringio'

module Bibliothecary
  module Parsers
    class Conda
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("environment.yml") => {
            parser: :parse_conda_environment
          },
          match_filename("environment.yaml") => {
            parser: :parse_conda_environment
          }
        }
      end

      def self.parse_conda_environment(file_contents)
        host = Bibliothecary.configuration.conda_parser_host
        response = Typhoeus.post(
          "#{host}/parse",
          headers: {
              ContentType: 'multipart/form-data'
          },
          body: {file: file_contents, filename: 'environment.yml'}
        )
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{host}/parse", response.response_code) unless response.success?

        json = JSON.parse(response.body, symbolize_names: true)

        # TODO: map these the right way, add `runtime` ?
      end
    end
  end
end
