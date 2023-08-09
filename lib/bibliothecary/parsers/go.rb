require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      GPM_REGEXP = /^(.+)\s+(.+)$/
      GOMOD_REGEX = /^(require\s+)?(.+)\s+(.+)$/
      GOMOD_IGNORABLE_REGEX = /^(\/\/|module\s|go\s|exclude\s|replace\s|require\s+\(|\))/m
      GOSUM_REGEX = /^(.+)\s+(.+)\s+(.+)$/

      def self.mapping
        {
          # Go Modules (recommended)
          match_filename("go.mod") => {
            kind: 'manifest',
            parser: :parse_go_mod
          },
          match_filename("go.sum") => {
            kind: 'lockfile',
            parser: :parse_go_sum
          },
          # Glide (unmaintained: https://github.com/Masterminds/glide#go-modules)
          match_filename("glide.yaml") => {
            kind: 'manifest',
            parser: :parse_glide_yaml
          },
          match_filename("glide.lock") => {
            kind: 'lockfile',
            parser: :parse_glide_lockfile
          },
          # Godep (unmaintained: https://github.com/tools/godep)
          match_filename("Godeps/Godeps.json") => {
            kind: 'manifest',
            parser: :parse_godep_json
          },
          match_filename("Godeps", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_gpm
          },
          # Govendor (unmaintained: https://github.com/kardianos/govendor)
          match_filename("vendor/manifest") => {
            kind: 'manifest',
            parser: :parse_gb_manifest
          },
          match_filename("vendor/vendor.json") => {
            kind: 'manifest',
            parser: :parse_govendor
          },
          # Go dep (deprecated: https://github.com/golang/dep#dep)
          match_filename("Gopkg.toml") => {
            kind: 'manifest',
            parser: :parse_dep_toml
          },
          match_filename("Gopkg.lock") => {
            kind: 'lockfile',
            parser: :parse_dep_lockfile
          },
          match_filename("go-resolved-dependencies.json") => {
            kind: 'lockfile',
            parser: :parse_go_resolved
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_godep_json(file_contents, options: {})
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'Deps', 'ImportPath', 'Rev', 'runtime')
      end

      def self.parse_gpm(file_contents, options: {})
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

      def self.parse_govendor(file_contents, options: {})
        manifest = JSON.load file_contents
        map_dependencies(manifest, 'package', 'path', 'revision', 'runtime')
      end

      def self.parse_glide_yaml(file_contents, options: {})
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'import', 'package', 'version', 'runtime') +
        map_dependencies(manifest, 'devImports', 'package', 'version', 'development')
      end

      def self.parse_glide_lockfile(file_contents, options: {})
        manifest = YAML.load file_contents
        map_dependencies(manifest, 'imports', 'name', 'version', 'runtime')
      end

      def self.parse_gb_manifest(file_contents, options: {})
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'dependencies', 'importpath', 'revision', 'runtime')
      end

      def self.parse_dep_toml(file_contents, options: {})
        manifest = Tomlrb.parse file_contents
        map_dependencies(manifest, 'constraint', 'name', 'version', 'runtime')
      end

      def self.parse_dep_lockfile(file_contents, options: {})
        manifest = Tomlrb.parse file_contents
        map_dependencies(manifest, 'projects', 'name', 'revision', 'runtime')
      end

      def self.parse_go_mod(file_contents, options: {})
        deps = []
        file_contents.lines.map(&:strip).each do |line|
          next if line.match(GOMOD_IGNORABLE_REGEX)
          if match = line.gsub(/(\/\/(.*))/, '').match(GOMOD_REGEX)
            deps << {
              name: match[2].strip,
              requirement: match[3].strip || '*',
              type: 'runtime'
            }
          end
        end
        deps
      end

      def self.parse_go_sum(file_contents, options: {})
        deps = []
        file_contents.lines.map(&:strip).each do |line|
          if match = line.match(GOSUM_REGEX)
            deps << {
              name: match[1].strip,
              requirement: match[2].strip.split('/').first || '*',
              type: 'runtime'
            }
          end
        end
        deps.uniq
      end

      def self.parse_go_resolved(file_contents, options: {})
        JSON.parse(file_contents)
          .select { |dep| dep["Main"] != "true" }
          .map { |dep| { name: dep["Path"], requirement: dep["Version"], type: dep.fetch("Scope") { "runtime" } } }
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
