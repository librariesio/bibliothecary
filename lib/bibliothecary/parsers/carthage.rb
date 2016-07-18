module Bibliothecary
  module Parsers
    class Carthage
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^Cartfile$/)
          file_contents = File.open(path).read
          parse_cartfile(file_contents)
        elsif filename.match(/^Cartfile\.private$/)
          file_contents = File.open(path).read
          parse_cartfile_private(file_contents)
        elsif filename.match(/^Cartfile\.resolved$/)
          file_contents = File.open(path).read
          parse_cartfile_resolved(file_contents)
        else
          []
        end
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
