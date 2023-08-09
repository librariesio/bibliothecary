require "json"
require 'deb_control'

module Bibliothecary
  module Parsers
    class Hackage
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_extension(".cabal") => {
            kind: 'manifest',
            parser: :parse_cabal
          },
          match_extension("cabal.config") => {
            kind: 'lockfile',
            parser: :parse_cabal_config
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_cabal(file_contents, options: {})
        headers = {
          'Content-Type' => "text/plain;charset=utf-8"
        }

        response = Typhoeus.post("#{Bibliothecary.configuration.cabal_parser_host}/parse", headers: headers, body: file_contents)

        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.cabal_parser_host}/parse", response.response_code) unless response.success?
        JSON.parse(response.body, symbolize_names: true)
      end

      def self.parse_cabal_config(file_contents, options: {})
        manifest = DebControl::ControlFileBase.parse(file_contents)
        deps = manifest.first['constraints'].delete("\n").split(',').map(&:strip)
        deps.map do |dependency|
          dep = dependency.delete("==").split(' ')
          {
            name: dep[0],
            requirement: dep[1] || '*',
            type: 'runtime'
          }
        end
      end
    end
  end
end
