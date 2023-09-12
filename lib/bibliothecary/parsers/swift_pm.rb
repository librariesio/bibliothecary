module Bibliothecary
  module Parsers
    class SwiftPM
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("Package.swift", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_package_swift
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_package_swift(file_contents, options: {})
        response = Typhoeus.post("#{Bibliothecary.configuration.swift_parser_host}/to-json", body: file_contents)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.swift_parser_host}/to-json", response.response_code) unless response.success?
        json = JSON.parse(response.body)
        json["dependencies"].map do |dependency|
          name = dependency['url'].gsub(/^https?:\/\//, '').gsub(/\.git$/,'')
          version = "#{dependency['version']['lowerBound']} - #{dependency['version']['upperBound']}"
          {
            name: name,
            requirement: version,
            type: 'runtime'
          }
        end
      end
    end
  end
end
