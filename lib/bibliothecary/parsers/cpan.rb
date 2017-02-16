require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class CPAN
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^META\.json$/i)
          file_contents = File.open(path).read
          parse_json_manifest(file_contents)
        elsif filename.match(/^META\.yml$/i)
          file_contents = File.open(path).read
          parse_yaml_manifest(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^META\.json$/i) || filename.match(/^META\.yml$/i)
      end

      def self.parse_json_manifest(file_contents)
        manifest = JSON.parse file_contents
        manifest['prereqs'].map do |group, deps|
          map_dependencies(deps, 'requires', 'runtime')
        end.flatten
      end

      def self.parse_yaml_manifest(file_contents)
        manifest = YAML.load file_contents
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
