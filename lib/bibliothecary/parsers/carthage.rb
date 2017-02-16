module Bibliothecary
  module Parsers
    class Carthage
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^Cartfile$/ => :parse_cartfile,
          /^Cartfile\.private$/ => :parse_cartfile_private,
          /^Cartfile\.resolved$/ => :parse_cartfile_resolved
        }
      end

      def self.parse_cartfile(manifest)
        response = Typhoeus.post("https://carthageparser.herokuapp.com/cartfile", params: {body: manifest})
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            version: dependency['version'],
            type: dependency["type"]
          }
        end
      end

      def self.parse_cartfile_private(manifest)
        response = Typhoeus.post("https://carthageparser.herokuapp.com/cartfile.private", params: {body: manifest})
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            version: dependency['version'],
            type: dependency["type"]
          }
        end
      end

      def self.parse_cartfile_resolved(manifest)
        response = Typhoeus.post("https://carthageparser.herokuapp.com/cartfile.resolved", params: {body: manifest})
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
