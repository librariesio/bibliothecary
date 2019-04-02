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

      def self.parse_package_swift(manifest)
        response = Typhoeus.post("#{Bibliothecary.configuration.swift_parser_host}/to-json", body: manifest)
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
