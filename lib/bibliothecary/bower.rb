require 'json'

module Bibliothecary
  class Bower
    def self.analyse(folder_path, file_list)
      path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^bower\.json$/) }
      return unless path

      manifest = JSON.parse File.open(path).read

      {
        platform: 'bower',
        path: path,
        dependencies: parse_manifest(manifest)
      }
    end

    def self.parse_manifest(manifest)
      map_dependencies(manifest, 'dependencies', 'runtime') +
      map_dependencies(manifest, 'devDependencies', 'development')
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
