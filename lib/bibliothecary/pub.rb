require 'yaml'

module Bibliothecary
  class Pub
    def self.analyse(folder_path, file_list)
      [
        analyse_yaml(folder_path, file_list),
        analyse_lockfile(folder_path, file_list)
      ]
    end

    def self.analyse_yaml(folder_path, file_list)
      path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^pubspec\.yaml$/i) }
      return unless path

      manifest = YAML.load File.open(path).read

      {
        platform: 'Pub',
        path: path,
        dependencies: parse_yaml_manifest(manifest)
      }
    end

    def self.analyse_lockfile(folder_path, file_list)
      path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^pubspec\.lock$/i) }
      return unless path

      manifest = YAML.load File.open(path).read

      {
        platform: 'Pub',
        path: path,
        dependencies: parse_yaml_manifest(manifest)
      }
    end

    def self.parse_yaml_manifest(manifest)
      map_dependencies(manifest, 'dependencies', 'runtime') +
      map_dependencies(manifest, 'dev_dependencies', 'development')
    end

    def self.parse_yaml_lockfile(manifest)
      manifest.fetch('packages', []).map do |name, dep|
        {
          name: name,
          requirement: dep['version'],
          type: type
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
