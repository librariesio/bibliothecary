require 'yaml'

module Bibliothecary
  module Parsers
    class Actions
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("action.yml") => {
            kind: 'manifest',
            parser: :parse_manifest
          },
          match_filename("action.yaml") => {
            kind: 'manifest',
            parser: :parse_manifest
          }
        }
      end

      def self.parse_manifest(file_contents, options: {})
        yaml = YAML.load(file_contents)
        case yaml['runs']['using']
        when /^node/
          [yaml['runs']['using'], yaml['runs']['main']] # https://github.com/actions/runner
        when 'docker'
          [yaml['runs']['image']]
        when 'composite'
          yaml['runs']['steps'].map { |step| step['uses'] }.compact
        else
          []
        end
      end
    end
  end
end
