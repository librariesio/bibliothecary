require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      GPM_REGEXP = /^(.+)\s+(.+)$/

      def self.mapping
        {
          /(^glide\.yaml$|.*\/glide\.yaml$)/ => {
            kind: 'manifest',
            parser: :parse_glide_yaml
          },
          /(^glide\.lock$|.*\/glide\.lock$)/ => {
            kind: 'lockfile',
            parser: :parse_glide_lockfile
          },
          /(^Godeps\/Godeps\.json$|.*\/Godeps\/Godeps\.json$)/ => {
            kind: 'manifest',
            parser: :parse_godep_json
          },
          /(^Godeps$|.*\/Godeps$)/i => {
            kind: 'manifest',
            parser: :parse_gpm
          },
          /(^vendor\/manifest$|.*\/vendor\/manifest$)/ => {
            kind: 'manifest',
            parser: :parse_gb_manifest
          },
          /(^vendor\/vendor.json$|.*\/vendor\/vendor.json$)/ => {
            kind: 'manifest',
            parser: :parse_govendor
          },
          /(^Gopkg\.toml$|.*\/Gopkg\.toml$)/ => {
            kind: 'manifest',
            parser: :parse_dep_toml
          },
          /(^Gopkg\.lock$|.*\/Gopkg\.lock$)/ => {
            kind: 'lockfile',
            parser: :parse_dep_lockfile
          },
        }
      end

      def self.parse_godep_json(file_contents)
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'Deps', 'ImportPath', 'Rev', 'runtime')
      end

      def self.parse_gpm(file_contents)
        deps = []
        file_contents.split("\n").each do |line|
          match = line.gsub(/(\#(.*))/, '').match(GPM_REGEXP)
          next unless match
          deps << {
            name: match[1].strip,
            requirement: match[2].strip || '*',
            type: 'runtime'
          }
        end
        deps
      end

      def self.parse_govendor(file_contents)
        manifest = JSON.load file_contents
        map_dependencies(manifest, 'package', 'path', 'revision', 'runtime')
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

      def self.parse_dep_toml(file_contents)
        manifest = TomlRB.parse file_contents
        map_dependencies(manifest, 'constraint', 'name', 'version', 'runtime')
      end

      def self.parse_dep_lockfile(file_contents)
        manifest = TomlRB.parse file_contents
        map_dependencies(manifest, 'projects', 'name', 'revision', 'runtime')
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
