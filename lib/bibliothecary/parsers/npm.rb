require 'json'

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^(?!node_modules).*package\.json$/ => {
            kind: 'manifest',
            parser: :parse_manifest
          },
          /^(?!node_modules).*npm-shrinkwrap\.json$/ => {
            kind: 'lockfile',
            parser: :parse_shrinkwrap
          },
          /^(?!node_modules).*yarn\.lock$/ => {
            kind: 'lockfile',
            parser: :parse_yarn_lock
          },
          /^(?!node_modules).*package-lock\.json$/ => {
            kind: 'lockfile',
            parser: :parse_package_lock
          }
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

      def self.parse_package_lock(file_contents)
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

      def self.parse_yarn_lock(file_contents)
        response = Typhoeus.post("https://yarn-parser.libraries.io/parse", body: file_contents)
        return [] unless response.response_code == 200
        json = JSON.parse(response.body, symbolize_names: true)
        json.uniq.map do |dep|
          {
            name: dep[:name],
            requirement: dep[:version],
            type: dep[:type]
          }
        end
      end
    end
  end
end
