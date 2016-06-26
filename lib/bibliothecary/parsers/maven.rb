require 'ox'

module Bibliothecary
  module Parsers
    class Maven
      PLATFORM_NAME = 'Maven'

      def self.parse(filename, file_contents)
        if filename.match(/^ivy\.xml$/i)
          xml = Ox.parse file_contents
          parse_ivy_manifest(xml)
        elsif filename.match(/^pom\.xml$/i)
          xml = Ox.parse file_contents
          parse_pom_manifest(xml)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_pom(folder_path, file_list),
        analyse_ivy(folder_path, file_list)]
      end

      def self.analyse_pom(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^pom\.xml$/i) }
        return unless path

        manifest = Ox.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_pom_manifest(manifest)
        }
      end

      def self.analyse_ivy(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^ivy.xml$/i) }
        return unless path
        p path
        manifest = Ox.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_ivy_manifest(manifest)
        }
      end

      def self.parse_ivy_manifest(manifest)
        manifest.dependencies.locate('dependency').map do |dependency|
          attrs = dependency.attributes
          {
            name: "#{attrs[:org]}:#{attrs[:name]}",
            requirement: attrs[:rev],
            type: 'runtime'
          }
        end
      end

      def self.parse_pom_manifest(manifest)
        manifest.project.dependencies.locate('dependency').map do |dependency|

          {
            name: "#{extract_pom_dep_info(manifest, dependency, 'groupId')}:#{extract_pom_dep_info(manifest, dependency, 'artifactId')}",
            requirement: extract_pom_dep_info(manifest, dependency, 'version'),
            type: extract_pom_dep_info(manifest, dependency, 'scope') || 'runtime'
          }
        end
      end

      def self.extract_pom_dep_info(manifest, dependency, name)
        field = dependency.locate(name).first
        return nil if field.nil?
        value = field.nodes.first
        if match = value.match(/^\$\{(.+)\}/)
          prop_field = manifest.project.properties.locate(match[1]).first
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
