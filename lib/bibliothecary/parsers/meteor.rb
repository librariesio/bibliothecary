require 'json'

module Bibliothecary
  module Parsers
    class Meteor
      PLATFORM_NAME = 'meteor'

      def self.parse(filename, file_contents)
        json = JSON.parse(file_contents)
        if filename.match(/^versions\.json$/)
          parse_manifest(json)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^versions\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: 'meteor',
          path: path,
          dependencies: parse_manifest(manifest)
        }
      end

      def self.parse_manifest(manifest)
        map_dependencies(manifest, 'dependencies', 'runtime')
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
