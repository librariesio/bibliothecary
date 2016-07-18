require 'json'

module Bibliothecary
  module Parsers
    class Hex
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^mix\.exs$/)
          file_contents = File.open(path).read
          parse_mix(file_contents)
        elsif filename.match(/^mix\.lock$/)
          file_contents = File.open(path).read
          parse_mix_lock(file_contents)
        else
          []
        end
      end

      def self.parse_mix(manifest)
        response = Typhoeus.post("https://mix-deps-json.herokuapp.com/", body: manifest)
        json = JSON.parse response.body

        json.map do |name, version|
          {
            name: name,
            version: version,
            type: "runtime"
          }
        end
      rescue
        []
      end

      def self.parse_mix_lock(manifest)
        response = Typhoeus.post("https://mix-deps-json.herokuapp.com/lock", body: manifest)
        json = JSON.parse response.body

        json.map do |name, info|
          {
            name: name,
            version: info['version'],
            type: "runtime"
          }
        end
      rescue
        []
      end
    end
  end
end
