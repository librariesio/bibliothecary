require 'yaml'

module Bibliothecary
  module Parsers
    class Shard
      PLATFORM_NAME = 'shard'

      def self.parse(filename, file_contents)
        if filename.match(/^shard\.yml$/i)
          yaml = YAML.load file_contents
          parse_yaml_manifest(yaml)
        elsif filename.match(/^shard\.lock$/i)
          yaml = YAML.load file_contents
          parse_yaml_lockfile(yaml)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_yaml_manifest(folder_path, file_list),
        analyse_yaml_lockfile(folder_path, file_list)]
      end

      def self.analyse_yaml_manifest(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^shard\.yml$/i) }
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

      def self.analyse_yaml_lockfile(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^shard\.lock$/i) }
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

      def self.parse_yaml_lockfile(manifest)
        map_dependencies(manifest, 'shards', 'runtime')
      end

      def self.parse_yaml_manifest(manifest)
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'development_dependencies', 'runtime')
      end

      def self.map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement['version'] || '*',
            type: type
          }
        end
      end
    end
  end
end
