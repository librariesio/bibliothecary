module Bibliothecary
  module Parsers
    class Carthage
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^Cartfile$/ => {
            kind: 'manifest',
            parser: :parse_cartfile
          },
          /^Cartfile\.private$/ => {
            kind: 'manifest',
            parser: :parse_cartfile_private
          },
          /^Cartfile\.resolved$/ => {
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
        response = Typhoeus.post("https://carthageparser.herokuapp.com/#{path}", params: {body: manifest})
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            version: dependency['version'],
            type: dependency["type"]
          }
        end
      end
    end
  end
end
