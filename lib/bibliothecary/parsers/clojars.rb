require 'json'
require 'typhoeus'

module Bibliothecary
  module Parsers
    class Clojars
      include Bibliothecary::Analyser

      def self.parse(filename, file_contents)
        if filename.match(/^project\.clj$/)
          parse_manifest(file_contents)
        else
          []
        end
      end

      def self.parse_manifest(manifest)
        response = Typhoeus.post("https://clojars-json.herokuapp.com/project.clj", body: manifest)
        json = JSON.parse response.body
        index = json.index("dependencies")

        return [] unless index;
        dependencies = json[index + 1]
        dependencies.map do |dependency|
          {
            name: dependency[0],
            version: dependency[1],
            type: "runtime"
          }
        end
      end
    end
  end
end
