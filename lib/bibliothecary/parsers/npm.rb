require 'json'

module Bibliothecary
  module Parsers
    class NPM
      def self.analyse(folder_path, file_list)
        [analyse_package_json(folder_path, file_list),
        analyse_shrinkwrap(folder_path, file_list)]
      end

      def self.analyse_package_json(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^package\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: 'npm',
          path: path,
          dependencies: parse_manifest(manifest)
        }
      end

      def self.analyse_shrinkwrap(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^npm-shrinkwrap\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: 'npm',
          path: path,
          dependencies: parse_shrinkwrap(manifest)
        }
      end

      def self.parse_shrinkwrap(manifest)
        manifest.fetch('dependencies',[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement["version"],
            type: 'runtime'
          }
        end
      end

      def self.parse_manifest(manifest)
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'devDependencies', 'development')
      end

      def self.map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: type
          }
        end
      end
    end
  end
end
