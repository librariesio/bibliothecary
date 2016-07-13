require 'toml'

module Bibliothecary
  module Parsers
    class Cargo
      PLATFORM_NAME = 'cargo'

      def self.parse(filename, file_contents)
        toml = TOML.parse(file_contents)
        if filename.match(/Cargo\.toml$/)
          parse_manifest(toml)
        elsif filename.match(/Cargo\.lock$/)
          parse_lockfile(toml)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_cargo_toml(folder_path, file_list),
          analyse_cargo_lock(folder_path, file_list)].flatten
      end

      def self.analyse_cargo_toml(folder_path, file_list)
        paths = file_list.select{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/Cargo\.toml$/) }
        return unless paths.any?

        paths.map do |path|
          manifest = TOML.load_file(path)

          {
            platform: PLATFORM_NAME,
            path: path,
            dependencies: parse_manifest(manifest)
          }
        end
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
        paths = file_list.select{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/Cargo\.lock$/) }
        return unless paths.any?

        paths.map do |path|
          manifest = TOML.load_file(path)

          {
            platform: PLATFORM_NAME,
            path: path,
            dependencies: parse_lockfile(manifest)
          }
        end
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
