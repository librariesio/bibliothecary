require "json"

module Bibliothecary
  module Parsers
    class Hex
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("mix.exs") => {
            kind: "manifest",
            parser: :parse_mix,
          },
          match_filename("mix.lock") => {
            kind: "lockfile",
            parser: :parse_mix_lock,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_mix(file_contents, options: {})
        source = options.fetch(:filename, 'mix.exs')
        response = Typhoeus.post("#{Bibliothecary.configuration.mix_parser_host}/", body: file_contents, timeout: 60)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.mix_parser_host}/", response.response_code) unless response.success?
        json = JSON.parse response.body

        deps = json.map do |name, version|
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: name,
            requirement: version,
            type: "runtime",
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      def self.parse_mix_lock(file_contents, options: {})
        source = options.fetch(:filename, 'mix.lock')
        response = Typhoeus.post("#{Bibliothecary.configuration.mix_parser_host}/lock", body: file_contents, timeout: 60)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.mix_parser_host}/", response.response_code) unless response.success?
        json = JSON.parse response.body

        deps = json.map do |name, info|
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: name,
            requirement: info["version"],
            type: "runtime",
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
