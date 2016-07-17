module Bibliothecary
  module Parsers
    class Swift
      PLATFORM_NAME = 'swift'

      def self.parse(filename, file_contents)
        if filename.match(/^Package\.swift$/i)
          parse_package_swift(file_contents)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_package_swift(folder_path, file_list)]
      end

      def self.analyse_package_swift(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Package\.swift$/i) }
        return unless path

        manifest = File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_package_swift(manifest)
        }
      rescue
        []
      end

      def self.parse_package_swift(manifest)
        response = Typhoeus.post("http://192.241.154.173/to-json", body: manifest)
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
