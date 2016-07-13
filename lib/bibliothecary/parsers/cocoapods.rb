require 'gemnasium/parser'
require 'yaml'

module Bibliothecary
  module Parsers
    class CocoaPods
      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'.freeze
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/

      PLATFORM_NAME = 'CocoaPods'

      def self.parse(filename, file_contents)

        if filename.match(/^Podfile$/)
          manifest = Gemnasium::Parser.send(:podfile, file_contents)
          parse_manifest(manifest)
        elsif filename.match(/^[A-Za-z0-9_-]+\.podspec$/)
          manifest = Gemnasium::Parser.send(:podspec, file_contents)
          parse_manifest(manifest)
        elsif filename.match(/^Podfile\.lock$/)
          manifest = YAML.load file_contents
          parse_podfile_lock(manifest)
        elsif filename.match(/^[A-Za-z0-9_-]+\.podspec.json$/)
          json = JSON.parse(file_contents)
          parse_json_manifest(json)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [
          analyse_podfile(folder_path, file_list),
          analyse_podspec(folder_path, file_list),
          analyse_podfile_lock(folder_path, file_list),
          analyse_podspec_json(folder_path, file_list)
        ].flatten
      end

      def self.analyse_podfile(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Podfile$/) }
        return unless path

        manifest = Gemnasium::Parser.send(:podfile, File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_manifest(manifest)
        }
      end

      def self.analyse_podspec(folder_path, file_list)
        paths = file_list.select{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^[A-Za-z0-9_-]+\.podspec$/) }
        return unless paths.any?

        paths.map do |path|
          manifest = Gemnasium::Parser.send(:podspec, File.open(path).read)

          {
            platform: PLATFORM_NAME,
            path: path,
            dependencies: parse_manifest(manifest)
          }
        end
      end

      def self.analyse_podspec_json(folder_path, file_list)
        paths = file_list.select{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^[A-Za-z0-9_-]+\.podspec.json$/) }
        return unless paths.any?

        paths.map do |path|
          manifest = JSON.parse File.open(path).read

          {
            platform: PLATFORM_NAME,
            path: path,
            dependencies: parse_json_manifest(manifest)
          }
        end
      end

      def self.analyse_podfile_lock(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Podfile\.lock$/) }
        return unless path

        manifest = YAML.load File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_podfile_lock(manifest)
        }
      end

      def self.parse_podfile_lock(manifest)
        manifest['PODS'].map do |row|
          pod = row.is_a?(String) ? row : row.keys.first
          match = pod.match(/(.+?)\s\((.+?)\)/i)
          {
            name: match[1].split('/').first,
            requirement: match[2],
            type: 'runtime'
          }
        end.compact
      end

      def self.parse_manifest(manifest)
        manifest.dependencies.inject([]) do |deps, dep|
          deps.push({
            name: dep.name,
            requirement: dep.requirement.to_s,
            type: dep.type
          })
        end.uniq
      end

      def self.parse_json_manifest(manifest)
        manifest['dependencies'].inject([]) do |deps, dep|
          deps.push({
            name: dep[0],
            requirement: dep[1],
            type: 'runtime'
          })
        end.uniq
      end
    end
  end
end
