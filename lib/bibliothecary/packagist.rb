require 'json'

module Bibliothecary
  class Packagist
    def self.analyse(folder_path, file_list)
      [analyse_composer_json(folder_path, file_list),
      analyse_composer_lock(folder_path, file_list)]
    end

    def self.analyse_composer_json(folder_path, file_list)
      path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^composer\.json$/) }
      return unless path

      manifest = JSON.parse File.open(path).read

      {
        platform: 'Packagist',
        path: path,
        dependencies: parse_manifest(manifest)
      }
    end

    def self.analyse_composer_lock(folder_path, file_list)
      path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^composer\.lock$/) }
      return unless path

      manifest = JSON.parse File.open(path).read

      {
        platform: 'Packagist',
        path: path,
        dependencies: parse_lockfile(manifest)
      }
    end

    def self.parse_lockfile(manifest)
      manifest.fetch('packages',[]).map do |dependency|
        {
          name: dependency["name"],
          requirement: dependency["version"],
          type: 'runtime'
        }
      end
    end

    def self.parse_manifest(manifest)
      map_dependencies(manifest, 'require', 'runtime') +
      map_dependencies(manifest, 'require-dev', 'development')
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
