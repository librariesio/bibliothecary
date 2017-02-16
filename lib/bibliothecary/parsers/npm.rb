require 'json'

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^package\.json$/)
          file_contents = File.open(path).read
          parse_manifest(file_contents)
        elsif filename.match(/^npm-shrinkwrap\.json$/)
          file_contents = File.open(path).read
          parse_shrinkwrap(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^package\.json$/) || filename.match(/^npm-shrinkwrap\.json$/)
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
