module Bibliothecary
  module Parsers
    class Swift
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^Package\.swift$/i)
          file_contents = File.open(path).read
          parse_package_swift(file_contents)
        else
          []
        end
      end

      def self.parse_package_swift(manifest)
        response = Typhoeus.post("http://swiftpm.honza.tech/to-json", body: manifest)
        json = JSON.parse(response.body)
        json["dependencies"].map do |dependency|
          name = dependency['url'].gsub(/^https?:\/\//, '').gsub(/\.git$/,'')
          version = "#{dependency['version']['lowerBound']} - #{dependency['version']['upperBound']}"
          {
            name: name,
            version: version,
            type: 'runtime'
          }
        end
      end
    end
  end
end
