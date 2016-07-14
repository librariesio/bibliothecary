require 'json'

module Bibliothecary
  module Parsers
    class Hex
      PLATFORM_NAME = 'hex'

      def self.parse(filename, file_contents)
        if filename.match(/^mix\.exs$/)
          parse_mix(file_contents)
        elsif filename.match(/^mix\.lock$/)
          parse_mix_lock(file_contents)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_mix(folder_path, file_list),
        analyse_mix_lock(folder_path, file_list)]
      end

      def self.analyse_mix(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^mix\.exs$/) }
        return unless path

        manifest = File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_mix(manifest)
        }
      end

      def self.analyse_mix_lock(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^mix\.lock$/) }
        return unless path

        manifest = File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_mix_lock(manifest)
        }
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
