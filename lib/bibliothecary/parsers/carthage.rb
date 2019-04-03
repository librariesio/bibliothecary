module Bibliothecary
  module Parsers
    class Carthage
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("Cartfile") => {
            kind: 'manifest',
            parser: :parse_cartfile
          },
          match_filename("Cartfile.private") => {
            kind: 'manifest',
            parser: :parse_cartfile_private
          },
          match_filename("Cartfile.resolved") => {
            kind: 'lockfile',
            parser: :parse_cartfile_resolved
          }
        }
      end

      def self.parse_cartfile(manifest)
        map_dependencies(manifest, 'cartfile')
      end

      def self.parse_cartfile_private(manifest)
        map_dependencies(manifest, 'cartfile.private')
      end

      def self.parse_cartfile_resolved(manifest)
        map_dependencies(manifest, 'cartfile.resolved')
      end

      def self.map_dependencies(manifest, path)
        response = Typhoeus.post("#{Bibliothecary.configuration.carthage_parser_host}/#{path}", params: {body: manifest})
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.carthage_parser_host}/#{path}", response.response_code) unless response.success?
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            requirement: dependency['version'],
            type: dependency["type"]
          }
        end
      end
    end
  end
end
