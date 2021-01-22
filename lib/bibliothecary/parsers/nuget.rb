require 'ox'
require 'json'

module Bibliothecary
  module Parsers
    class Nuget
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("Project.json") => {
            kind: 'manifest',
            parser: :parse_json_runtime_manifest
          },
          match_filename("Project.lock.json") => {
            kind: 'lockfile',
            parser: :parse_project_lock_json
          },
          match_filename("packages.lock.json") => {
            kind: 'lockfile',
            parser: :parse_packages_lock_json
          },
          match_filename("packages.config") => {
            kind: 'manifest',
            parser: :parse_packages_config
          },
          match_extension(".nuspec") => {
            kind: 'manifest',
            parser: :parse_nuspec
          },
          match_extension(".csproj") => {
            kind: 'manifest',
            parser: :parse_csproj
          },
          match_filename("paket.lock") => {
            kind: 'lockfile',
            parser: :parse_paket_lock
          }
        }
      end

      def self.parse_project_lock_json(file_contents)
        manifest = JSON.parse file_contents
        manifest.fetch('libraries',[]).map do |name, _requirement|
          dep = name.split('/')
          {
            name: dep[0],
            requirement: dep[1],
            type: 'runtime'
          }
        end
      end

      def self.parse_packages_lock_json(file_contents)
        manifest = JSON.parse file_contents

        frameworks = {}
        manifest.fetch('dependencies',[]).each do |framework, deps|
          frameworks[framework] = deps.map do |name, details|
            {
              name: name,
              # 'resolved' has been set in all examples so far
              # so fallback to requested is pure paranoia
              requirement: details.fetch('resolved', details.fetch('requested', '*')),
              type: 'runtime'
            }
          end
        end

        if frameworks.size > 0
          # we should really return multiple manifests, but bibliothecary doesn't
          # do that yet so at least pick deterministically.

          # Note, frameworks can be empty, so remove empty ones and then return the last sorted item if any
          frameworks = frameworks.delete_if { |k, v| v.empty? }
          return frameworks[frameworks.keys.sort.last] unless frameworks.empty?
        end
        []
      end

      def self.parse_packages_config(file_contents)
        manifest = Ox.parse file_contents
        manifest.packages.locate('package').map do |dependency|
          {
            name: dependency.id,
            requirement: (dependency.version if dependency.respond_to? "version") || "*",
            type: 'runtime'
          }
        end
      rescue
        []
      end

      def self.parse_csproj(file_contents)
        manifest = Ox.parse file_contents
        packages = manifest.locate('ItemGroup/PackageReference').map do |dependency|
          {
            name: dependency.Include,
            requirement: (dependency.Version if dependency.respond_to? "Version") || "*",
            type: 'runtime'
          }
        end
        packages.uniq {|package| package[:name] }
      rescue
        []
      end

      def self.parse_nuspec(file_contents)
        manifest = Ox.parse file_contents
        manifest.package.metadata.dependencies.locate('dependency').map do |dependency|
          {
            name: dependency.id,
            requirement: dependency.attributes[:version] || '*',
            type: 'runtime'
          }
        end
      rescue
        []
      end

      def self.parse_paket_lock(file_contents)
        lines = file_contents.split("\n")
        package_version_re = /\s+(?<name>\S+)\s\((?<version>\d+\.\d+[\.\d+[\.\d+]*]*)\)/
        packages = lines.select { |line| package_version_re.match(line) }.map { |line| package_version_re.match(line) }.map do |match|
          {
            name: match[:name].strip,
            requirement: match[:version],
            type: 'runtime'
          }
        end
        # we only have to enforce uniqueness by name because paket ensures that there is only the single version globally in the project
        packages.uniq {|package| package[:name] }
      end
    end
  end
end
