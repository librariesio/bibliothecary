require 'json'

module Bibliothecary
  module Parsers
    class Elm
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::JSONRuntime

      def self.mapping
        {
          match_filenames("elm-package.json", "elm_dependencies.json") => {
            kind: 'manifest',
            parser: :parse_json_runtime_manifest
          },
          match_filename("elm-stuff/exact-dependencies.json") => {
            kind: 'lockfile',
            parser: :parse_json_lock
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_json_lock(file_contents, options: {})
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
