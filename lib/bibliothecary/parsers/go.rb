require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      GPM_REGEXP = /^(.+)\s+(.+)$/

      def self.mapping
        {
          match_filename("glide.yaml") => {
            kind: 'manifest',
            parser: :parse_glide_yaml
          },
          match_filename("glide.lock") => {
            kind: 'lockfile',
            parser: :parse_glide_lockfile
          },
          match_filename("Godeps/Godeps.json") => {
            kind: 'manifest',
            parser: :parse_godep_json
          },
          match_filename("Godeps", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_gpm
          },
          match_filename("vendor/manifest") => {
            kind: 'manifest',
            parser: :parse_gb_manifest
          },
          match_filename("vendor/vendor.json") => {
            kind: 'manifest',
            parser: :parse_govendor
          },
          match_filename("Gopkg.toml") => {
            kind: 'manifest',
            parser: :parse_dep_toml
          },
          match_filename("Gopkg.lock") => {
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
