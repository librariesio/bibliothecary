require 'ox'

module Bibliothecary
  module Parsers
    class Maven
      include Bibliothecary::Analyser

      def self.mapping
        {
          /ivy\.xml$/i => {
            kind: 'manifest',
            parser: :parse_ivy_manifest
          },
          /pom\.xml$/i => {
            kind: 'manifest',
            parser: :parse_pom_manifest
          },
          /build.gradle$/i => {
            kind: 'manifest',
            parser: :parse_gradle
          }
        }
      end

      def self.parse_ivy_manifest(file_contents)
        manifest = Ox.parse file_contents
        manifest.dependencies.locate('dependency').map do |dependency|
          attrs = dependency.attributes
          {
            name: "#{attrs[:org]}:#{attrs[:name]}",
            requirement: attrs[:rev],
            type: 'runtime'
          }
        end
      rescue
        []
      end

      def self.parse_pom_manifest(file_contents)
        manifest = Ox.parse file_contents
        if manifest.respond_to?('project')
          xml = manifest.project
        else
          xml = manifest
        end
        return [] unless xml.respond_to?('dependencies')
        xml.dependencies.locate('dependency').map do |dependency|
          {
            name: "#{extract_pom_dep_info(xml, dependency, 'groupId')}:#{extract_pom_dep_info(xml, dependency, 'artifactId')}",
            requirement: extract_pom_dep_info(xml, dependency, 'version'),
            type: extract_pom_dep_info(xml, dependency, 'scope') || 'runtime'
          }
        end
      rescue
        []
      end

      def self.parse_gradle(manifest)
        response = Typhoeus.post("https://gradle-parser.libraries.io/parse", body: manifest)
        json = JSON.parse(response.body)
        return [] unless json['dependencies']
        json['dependencies'].map do |dependency|
          name = [dependency["group"], dependency["name"]].join(':')
          next unless name =~ (/[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+(\.[A-Za-z0-9_-])?\:[A-Za-z0-9_-]/)
          {
            name: name,
            version: dependency["version"],
            type: dependency["type"]
          }
        end.compact
      end

      def self.extract_pom_dep_info(xml, dependency, name)
        field = dependency.locate(name).first
        return nil if field.nil?
        value = field.nodes.first
        match = value.match(/^\$\{(.+)\}/)
        if match
          prop_field = xml.properties.locate(match[1]).first
          if prop_field
            return prop_field.nodes.first
          else
            return value
          end
        else
          return value
        end
      end
    end
  end
end
