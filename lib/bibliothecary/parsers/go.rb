require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      PLATFORM_NAME = 'go'

      def self.parse(filename, file_contents)
        if filename.match(/^glide\.yaml$/)
          yaml = YAML.load file_contents
          parse_glide_yaml(yaml)
        elsif filename.match(/^glide\.lock$/)
          yaml = YAML.load file_contents
          parse_glide_lockfile(yaml)
        elsif filename.match(/^Godeps\/Godeps\.json$/)
          json = JSON.parse file_contents
          parse_godep_json(json)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_glide_yaml(folder_path, file_list),
        analyse_glide_lockfile(folder_path, file_list),
        analyse_godep_json(folder_path, file_list)]
      end

      def self.analyse_godep_json(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Godeps\/Godeps\.json$/) }
        return unless path

        manifest = JSON.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_godep_json(manifest)
        }
      end

      def self.analyse_glide_yaml(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^glide\.yaml$/) }
        return unless path

        manifest = YAML.load File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_glide_yaml(manifest)
        }
      end

      def self.analyse_glide_lockfile(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^glide\.lock$/) }
        return unless path

        manifest = YAML.load File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_glide_lockfile(manifest)
        }
      end

      def self.parse_godep_json(manifest)
        manifest.fetch('Deps',[]).map do |dependency|
          {
            name: dependency['ImportPath'],
            requirement: dependency['Rev'],
            type: 'runtime'
          }
        end
      end

      def self.parse_glide_yaml(manifest)
        manifest.fetch('import',[]).map do |dependency|
          {
            name: dependency['package'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end + manifest.fetch('devImports',[]).map do |dependency|
          {
            name: dependency['package'],
            requirement: dependency['version'] || '*',
            type: 'development'
          }
        end
      end

      def self.parse_glide_lockfile(manifest)
        manifest.fetch('imports',[]).map do |dependency|
          {
            name: dependency['name'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end
      end
    end
  end
end
