require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class CPAN
      PLATFORM_NAME = 'cpan'

      def self.parse(filename, file_contents)
        if filename.match(/^META\.json$/i)
          json = JSON.parse file_contents
          parse_json_manifest(json)
        elsif filename.match(/^META\.yml$/i)
          yaml = YAML.load file_contents
          parse_yaml_manifest(yaml)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_json(folder_path, file_list),
        analyse_yaml(folder_path, file_list)]
      end

      def self.analyse_json(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^META\.json$/i) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_json_manifest(manifest)
        }
      end

      def self.analyse_yaml(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^META\.yml$/i) }
        return unless path

        manifest = YAML.load File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_yaml_manifest(manifest)
        }
      end

      def self.parse_json_manifest(manifest)
        manifest['prereqs'].map do |group, deps|
          map_dependencies(deps, 'requires', 'runtime')
        end.flatten
      end

      def self.parse_yaml_manifest(manifest)
        map_dependencies(manifest, 'requires', 'runtime')
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
