require 'json'

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^package\.json$/ => :parse_manifest,
          /^npm-shrinkwrap\.json$/ => :parse_shrinkwrap
        }
      end

      def self.parse_shrinkwrap(file_contents)
        manifest = JSON.parse(file_contents)
        manifest.fetch('dependencies',[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement["version"],
            type: 'runtime'
          }
        end
      end

      def self.parse_manifest(file_contents)
        manifest = JSON.parse(file_contents)
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'devDependencies', 'development')
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
