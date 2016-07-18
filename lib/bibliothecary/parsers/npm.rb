require 'json'

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      def self.parse(filename, file_contents)
        if filename.match(/package\.json$/)
          json = JSON.parse(file_contents)
          parse_manifest(json)
        elsif filename.match(/npm-shrinkwrap\.json$/)
          json = JSON.parse(file_contents)
          parse_shrinkwrap(json)
        else
          []
        end
      end

      def self.parse_shrinkwrap(manifest)
        manifest.fetch('dependencies',[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement["version"],
            type: 'runtime'
          }
        end
      end

      def self.parse_manifest(manifest)
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
