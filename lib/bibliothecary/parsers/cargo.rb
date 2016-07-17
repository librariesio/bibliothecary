require 'toml'

module Bibliothecary
  module Parsers
    class Cargo
      include Bibliothecary::Analyser

      def self.parse(filename, file_contents)
        if filename.match(/Cargo\.toml$/)
          toml = TOML.parse(file_contents)
          parse_manifest(toml)
        elsif filename.match(/Cargo\.lock$/)
          toml = TOML.parse(file_contents)
          parse_lockfile(toml)
        else
          []
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
      rescue
        []
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
