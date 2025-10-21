require "json"
require "deb_control"

module Bibliothecary
  module Parsers
    class Hackage
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_extension(".cabal") => {
            kind: "manifest",
            parser: :parse_cabal,
          },
          match_extension("cabal.config") => {
            kind: "lockfile",
            parser: :parse_cabal_config,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_cabal(file_contents, options: {})
        source = options.fetch(:filename, 'package.cabal')
        headers = {
          "Content-Type" => "text/plain;charset=utf-8",
        }

        response = Typhoeus.post("#{Bibliothecary.configuration.cabal_parser_host}/parse", headers: headers, body: file_contents, timeout: 60)

        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.cabal_parser_host}/parse", response.response_code) unless response.success?
        raw_deps = JSON.parse(response.body, symbolize_names: true)
        deps = raw_deps.map do |dep|
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: dep[:name],
            requirement: dep[:requirement],
            type: dep[:type],
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      def self.parse_cabal_config(file_contents, options: {})
        source = options.fetch(:filename, 'cabal.config')
        manifest = DebControl::ControlFileBase.parse(file_contents)
        deps_raw = manifest.first["constraints"].delete("\n").split(",").map(&:strip)
        deps = deps_raw.map do |dependency|
          dep = dependency.delete("==").split(" ")
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: dep[0],
            requirement: dep[1] || "*",
            type: "runtime",
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
