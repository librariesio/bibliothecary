require 'yaml'

module Bibliothecary
  module Parsers
    class Pub
      PLATFORM_NAME = 'Pub'

      def self.parse(filename, file_contents)
        yaml = YAML.load file_contents
        if filename.match(/^pubspec\.yaml$/i)
          parse_yaml_manifest(yaml)
        elsif filename.match(/^pubspec\.lock$/i)
          parse_yaml_lockfile(yaml)
        else
          []
        end
      end

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
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_yaml_manifest(manifest)
        }
      rescue
        []
      end

      def self.analyse_lockfile(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^pubspec\.lock$/i) }
        return unless path

        manifest = YAML.load File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_yaml_lockfile(manifest)
        }
      rescue
        []
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
