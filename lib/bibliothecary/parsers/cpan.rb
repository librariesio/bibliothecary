require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class CPAN
      include Bibliothecary::Analyser

      def self.mapping
        {
          /(^META\.json$|.*\/META\.json$)/i => {
            kind: 'manifest',
            parser: :parse_json_manifest
          },
          /(^META\.yml$|.*\/META.yml$)/i => {
            kind: 'manifest',
            parser: :parse_yaml_manifest
          }
        }
      end

      def self.parse_json_manifest(file_contents)
        manifest = JSON.parse file_contents
        manifest['prereqs'].map do |_group, deps|
          map_dependencies(deps, 'requires', 'runtime')
        end.flatten
      end

      def self.parse_yaml_manifest(file_contents)
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'requires', 'runtime')
      end
    end
  end
end
