require 'json'

module Bibliothecary
  module Parsers
    class Elm
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^elm-package\.json$|^elm_dependencies\.json$/ => {
            kind: 'manifest',
            parser: :parse_json_runtime_manifest
          },
          /^elm-stuff\/exact-dependencies\.json$/ => {
            kind: 'lockfile',
            parser: :parse_json_lock
          }
        }
      end

      def self.parse_json_lock(file_contents)
        manifest = JSON.parse file_contents
        manifest.map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
      end
    end
  end
end
