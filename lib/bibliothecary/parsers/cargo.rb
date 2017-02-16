require 'toml'

module Bibliothecary
  module Parsers
    class Cargo
      include Bibliothecary::Analyser

      def self.mapping
        {
          /Cargo\.toml$/ => :parse_manifest,
          /Cargo\.lock$/ => :parse_lockfile
        }
      end

      def self.parse_manifest(file_contents)
        manifest = TOML.parse(file_contents)
        manifest.fetch('dependencies', []).map do |name, requirement|
          if requirement.respond_to?(:fetch)
            requirement = requirement['version'] or next
          end
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
          .compact
      end

      def self.parse_lockfile(file_contents)
        manifest = TOML.parse(file_contents)
        manifest.fetch('package',[]).map do |dependency|
          next if not dependency['source'] or not dependency['source'].start_with?('registry+')
          {
            name: dependency['name'],
            requirement: dependency['version'],
            type: 'runtime'
          }
        end
          .compact
      end
    end
  end
end
