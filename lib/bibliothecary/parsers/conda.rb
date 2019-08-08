require 'json'

module Bibliothecary
  module Parsers
    class Conda
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("environment.yml") => {
            kind: 'manifest',
            parser: :parse_yaml_manifest
          }
        }
      end

      def self.parse_yaml_manifest(file_contents)
        unparsed_manifest = YAML.load file_contents

        manifest = {}
        manifest["dependencies"] = unparsed_manifest["dependencies"].map do |dep|
           fields = dep.split("=")

           fields << ">= 0" # Add fallback for version if no version specified

           fields[0..2]
        end

        map_dependencies(manifest, 'dependencies', 'runtime')
      end
    end
  end
end
