require 'json'

module Bibliothecary
  module Parsers
    class Hex
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("mix.exs") => {
            kind: 'manifest',
            parser: :parse_mix
          },
          match_filename("mix.lock") => {
            kind: 'lockfile',
            parser: :parse_mix_lock
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_mix(file_contents, options: {})
        response = Typhoeus.post("#{Bibliothecary.configuration.mix_parser_host}/", body: file_contents)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.mix_parser_host}/", response.response_code) unless response.success?
        json = JSON.parse response.body

        json.map do |name, version|
          {
            name: name,
            requirement: version,
            type: "runtime"
          }
        end
      end

      def self.parse_mix_lock(file_contents, options: {})
        response = Typhoeus.post("#{Bibliothecary.configuration.mix_parser_host}/lock", body: file_contents)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.mix_parser_host}/", response.response_code) unless response.success?
        json = JSON.parse response.body

        json.map do |name, info|
          {
            name: name,
            requirement: info['version'],
            type: "runtime"
          }
        end
      end
    end
  end
end
