require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^glide\.yaml$/ => :parse_glide_yaml,
          /^glide\.lock$/ => :parse_glide_lockfile,
          /^Godeps\/Godeps\.json$/ => :parse_godep_json,
          /^vendor\/manifest$/ => :parse_gb_manifest
        }
      end

      def self.parse_godep_json(file_contents)
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'Deps', 'ImportPath', 'Rev', 'runtime')
      end

      def self.parse_glide_yaml(file_contents)
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'import', 'package', 'version', 'runtime') +
        map_dependencies(manifest, 'devImports', 'package', 'version', 'development')
      end

      def self.parse_glide_lockfile(file_contents)
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'imports', 'name', 'version', 'runtime')
      end

      def self.parse_gb_manifest(file_contents)
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'dependencies', 'importpath', 'revision', 'runtime')
      end

      def self.map_dependencies(manifest, attr_name, dep_attr_name, version_attr_name, type)
        manifest.fetch(attr_name,[]).map do |dependency|
          {
            name: dependency[dep_attr_name],
            requirement: dependency[version_attr_name]  || '*',
            type: type
          }
        end
      end
    end
  end
end
