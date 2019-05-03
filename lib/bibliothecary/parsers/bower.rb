require 'json'

module Bibliothecary
  module Parsers
    class Bower
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("bower.json") => {
            kind: 'manifest',
            parser: :parse_manifest
          }
        }
      end

      def self.parse_manifest(manifest)
        json = JSON.parse(manifest)
        map_dependencies(json, 'dependencies', 'runtime') +
        map_dependencies(json, 'devDependencies', 'development')
      end
    end
  end
end
