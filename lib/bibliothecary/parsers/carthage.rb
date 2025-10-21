module Bibliothecary
  module Parsers
    class Carthage
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("Cartfile") => {
            kind: "manifest",
            parser: :parse_cartfile,
          },
          match_filename("Cartfile.private") => {
            kind: "manifest",
            parser: :parse_cartfile_private,
          },
          match_filename("Cartfile.resolved") => {
            kind: "lockfile",
            parser: :parse_cartfile_resolved,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_cartfile(file_contents, options: {})
        map_dependencies(file_contents, "cartfile", options.fetch(:filename, "Cartfile"))
      end

      def self.parse_cartfile_private(file_contents, options: {})
        map_dependencies(file_contents, "cartfile.private", options.fetch(:filename, "Cartfile.private"))
      end

      def self.parse_cartfile_resolved(file_contents, options: {})
        map_dependencies(file_contents, "cartfile.resolved", options.fetch(:filename, "Cartfile.resolved"))
      end

      def self.map_dependencies(manifest, path, source)
        response = Typhoeus.post("#{Bibliothecary.configuration.carthage_parser_host}/#{path}", params: {body: manifest}, timeout: 60)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.carthage_parser_host}/#{path}", response.response_code) unless response.success?
        json = JSON.parse(response.body)

        deps = json.map do |dependency|
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: dependency["name"],
            requirement: dependency["version"],
            type: dependency["type"],
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
