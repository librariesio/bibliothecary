require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class CPAN
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^META\.json$/i)
          file_contents = File.open(path).read
          json = JSON.parse file_contents
          parse_json_manifest(json)
        elsif filename.match(/^META\.yml$/i)
          file_contents = File.open(path).read
          yaml = YAML.load file_contents
          parse_yaml_manifest(yaml)
        else
          []
        end
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
