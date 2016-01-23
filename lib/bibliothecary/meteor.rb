require 'json'

module Bibliothecary
  class Meteor
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
