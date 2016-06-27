require 'json'

module Bibliothecary
  module Parsers
    class Elm
      PLATFORM_NAME = 'elm'

      def self.parse(filename, file_contents)
        if filename.match(/^elm-package\.json$|^elm_dependencies\.json$/)
          json = JSON.parse file_contents
          parse_json_manifest(json)
        elsif filename.match(/^elm-stuff\/exact-dependencies\.json$/)
          json = JSON.parse file_contents
          parse_json_lock(json)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_json(folder_path, file_list),
        analyse_json_lock(folder_path, file_list)]
      end

      def self.analyse_json(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^elm-package\.json$|^elm_dependencies\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_json_manifest(manifest)
        }
      end

      def self.analyse_json_lock(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^elm-stuff\/exact-dependencies\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_json_lock(manifest)
        }
      end

      def self.parse_json_manifest(manifest)
        map_dependencies(manifest, 'dependencies', 'runtime')
      end

      def self.parse_json_lock(manifest)
        manifest.map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
      end

      def self.map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: type
          }
        end
      end
    end
  end
end
