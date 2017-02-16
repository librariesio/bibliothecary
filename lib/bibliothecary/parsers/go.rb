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
        manifest.fetch('Deps',[]).map do |dependency|
          {
            name: dependency['ImportPath'],
            requirement: dependency['Rev'],
            type: 'runtime'
          }
        end
      end

      def self.parse_glide_yaml(file_contents)
        manifest = YAML.load file_contents
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

      def self.parse_glide_lockfile(file_contents)
        manifest = YAML.load file_contents
        manifest.fetch('imports',[]).map do |dependency|
          {
            name: dependency['name'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end
      end

      def self.parse_gb_manifest(file_contents)
        manifest = JSON.parse file_contents
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
