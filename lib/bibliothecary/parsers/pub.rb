require 'yaml'

module Bibliothecary
  module Parsers
    class Pub
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^pubspec\.yaml$/i)
          file_contents = File.open(path).read
          yaml = YAML.load file_contents
          parse_yaml_manifest(yaml)
        elsif filename.match(/^pubspec\.lock$/i)
          file_contents = File.open(path).read
          yaml = YAML.load file_contents
          parse_yaml_lockfile(yaml)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^pubspec\.yaml$/i) || filename.match(/^pubspec\.lock$/i)
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
