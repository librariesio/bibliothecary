require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      def self.parse(filename, file_contents)
        if filename.match(/^glide\.yaml$/)
          yaml = YAML.load file_contents
          parse_glide_yaml(yaml)
        elsif filename.match(/^glide\.lock$/)
          yaml = YAML.load file_contents
          parse_glide_lockfile(yaml)
        elsif filename.match(/^Godeps\/Godeps\.json$/)
          json = JSON.parse file_contents
          parse_godep_json(json)
        elsif filename.match(/^vendor\/manifest$/)
          json = JSON.parse file_contents
          parse_gb_manifest(json)
        else
          []
        end
      end

      def self.parse_godep_json(manifest)
        manifest.fetch('Deps',[]).map do |dependency|
          {
            name: dependency['ImportPath'],
            requirement: dependency['Rev'],
            type: 'runtime'
          }
        end
      end

      def self.parse_glide_yaml(manifest)
        manifest.fetch('import',[]).map do |dependency|
          {
            name: dependency['package'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end + manifest.fetch('devImports',[]).map do |dependency|
          {
            name: dependency['package'],
            requirement: dependency['version'] || '*',
            type: 'development'
          }
        end
      end

      def self.parse_glide_lockfile(manifest)
        manifest.fetch('imports',[]).map do |dependency|
          {
            name: dependency['name'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end
      end

      def self.parse_gb_manifest(manifest)
        manifest.fetch('dependencies',[]).map do |dependency|
          {
            name: dependency['importpath'],
            requirement: dependency['revision'],
            type: 'runtime'
          }
        end
      end
    end
  end
end
