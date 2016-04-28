require 'toml'

module Bibliothecary
  module Parsers
    class Cargo
      def self.analyse(folder_path, file_list)
        [analyse_cargo_toml(folder_path, file_list),
          analyse_cargo_lock(folder_path, file_list)]
      end

      def self.analyse_cargo_toml(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cargo\.toml$/) }
        return unless path

        manifest = TOML.load_file(path)

        {
          platform: 'cargo',
          path: path,
          dependencies: parse_manifest(manifest)
        }
      end

      def self.parse_manifest(manifest)
        manifest.fetch('dependencies', []).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
      end

      def self.analyse_cargo_lock(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cargo\.lock$/) }
        return unless path

        manifest = TOML.load_file(path)

        {
          platform: 'cargo',
          path: path,
          dependencies: parse_lockfile(manifest)
        }
      end

      def self.parse_lockfile(manifest)
        manifest.fetch('package',[]).map do |dependency|
          {
            name: dependency['name'],
            requirement: dependency['version'],
            type: 'runtime'
          }
        end
      end
    end
  end
end
