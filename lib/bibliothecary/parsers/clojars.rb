require 'json'
require 'typhoeus'

module Bibliothecary
  module Parsers
    class Clojars
      PLATFORM_NAME = 'clojars'

      def self.parse(filename, file_contents)
        if filename.match(/^project\.clj$/)
          parse_manifest(file_contents)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_manifest(folder_path, file_list)]
      end

      def self.analyse_manifest(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^project\.clj$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_json_manifest(manifest)
        }
      rescue
        []
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
