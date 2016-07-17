require 'ox'
require 'json'

module Bibliothecary
  module Parsers
    class Nuget
      include Bibliothecary::Analyser

      def self.parse(filename, file_contents)
        if filename.match(/Project\.json$/)
          json = JSON.parse file_contents
          parse_project_json(json)
        elsif filename.match(/Project\.lock\.json$/)
          json = JSON.parse file_contents
          parse_project_lock_json(json)
        elsif filename.match(/packages\.config$/)
          xml = Ox.parse file_contents
          parse_packages_config(xml)
        elsif filename.match(/^[A-Za-z0-9_-]+\.nuspec$/)
          xml = Ox.parse file_contents
          parse_nuspec(xml)
        elsif filename.match(/paket\.lock$/)
          parse_paket_lock(file_contents.split("\n"))
        else
          []
        end
      end

      def self.parse_project_json(manifest)
        manifest.fetch('dependencies',[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
      end

      def self.parse_project_lock_json(manifest)
        manifest.fetch('libraries',[]).map do |name, requirement|
          dep = name.split('/')
          {
            name: dep[0],
            requirement: dep[1],
            type: 'runtime'
          }
        end
      end

      def self.parse_packages_config(manifest)
        manifest.packages.locate('package').map do |dependency|
          {
            name: dependency.id,
            version: dependency.version,
            type: 'runtime'
          }
        end
      end

      def self.parse_nuspec(manifest)
        manifest.package.metadata.dependencies.locate('dependency').map do |dependency|
          {
            name: dependency.id,
            version: dependency.attributes[:version] || '*',
            type: 'runtime'
          }
        end
      end

      def self.parse_paket_lock(lines)
        package_version_re = /\s+(?<name>\S+)\s\((?<version>\d+\.\d+[\.\d+[\.\d+]*]*)\)/
        packages = lines.select { |line| package_version_re.match(line) }.map { |line| package_version_re.match(line) }.map do |match|
          {
            name: match[:name].strip,
            version: match[:version],
            type: 'runtime'
          }
        end
        # we only have to enforce uniqueness by name because paket ensures that there is only the single version globally in the project
        packages.uniq {|package| package[:name] }
      end
    end
  end
end
