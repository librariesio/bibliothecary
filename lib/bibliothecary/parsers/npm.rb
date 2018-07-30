require 'json'

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^package\.json$|.*\/package\.json$/ => {
            kind: 'manifest',
            parser: :parse_manifest
          },
          /^npm-shrinkwrap\.json$|.*\/npm-shrinkwrap\.json$/ => {
            kind: 'lockfile',
            parser: :parse_shrinkwrap
          },
          /^yarn\.lock$|.*\/yarn.lock$/ => {
            kind: 'lockfile',
            parser: :parse_yarn_lock
          },
          /^package-lock\.json$|.*\/package-lock\.json$/ => {
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
        response = Typhoeus.post("#{Bibliothecary.configuration.yarn_parser_host}/parse", body: file_contents)

        raise Bibliothecary::ParseHostError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.yarn_parser_host}/parse", response.response_code) unless response.success?

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
