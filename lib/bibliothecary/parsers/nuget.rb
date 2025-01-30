# frozen_string_literal: true

require "ox"
require "json"

module Bibliothecary
  module Parsers
    class Nuget
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::JSONRuntime

      def self.mapping
        {
          match_filename("Project.json") => {
            kind: "manifest",
            parser: :parse_json_runtime_manifest,
          },
          match_filename("Project.lock.json") => {
            kind: "lockfile",
            parser: :parse_project_lock_json,
          },
          match_filename("packages.lock.json") => {
            kind: "lockfile",
            parser: :parse_packages_lock_json,
          },
          match_filename("packages.config") => {
            kind: "manifest",
            parser: :parse_packages_config,
          },
          match_extension(".nuspec") => {
            kind: "manifest",
            parser: :parse_nuspec,
          },
          match_extension(".csproj") => {
            kind: "manifest",
            parser: :parse_csproj,
          },
          match_filename("paket.lock") => {
            kind: "lockfile",
            parser: :parse_paket_lock,
          },
          match_filename("project.assets.json") => {
            kind: "lockfile",
            parser: :parse_project_assets_json,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_project_lock_json(file_contents, options: {})
        manifest = JSON.parse file_contents
        manifest.fetch("libraries", []).map do |name, _requirement|
          dep = name.split("/")
          Dependency.new(
            name: dep[0],
            requirement: dep[1],
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end
      end

      def self.parse_packages_lock_json(file_contents, options: {})
        manifest = JSON.parse file_contents

        frameworks = {}
        manifest.fetch("dependencies", []).each do |framework, deps|
          frameworks[framework] = deps
            .reject { |_name, details| details["type"] == "Project" } # Projects do not have versions
            .map do |name, details|
              Dependency.new(
                name: name,
                # 'resolved' has been set in all examples so far
                # so fallback to requested is pure paranoia
                requirement: details.fetch("resolved", details.fetch("requested", "*")),
                type: "runtime",
                source: options.fetch(:filename, nil)
              )
            end
        end

        unless frameworks.empty?
          # we should really return multiple manifests, but bibliothecary doesn't
          # do that yet so at least pick deterministically.

          # Note, frameworks can be empty, so remove empty ones and then return the last sorted item if any
          frameworks = frameworks.delete_if { |_k, v| v.empty? }
          return frameworks[frameworks.keys.max] unless frameworks.empty?
        end
        []
      end

      def self.parse_packages_config(file_contents, options: {})
        manifest = Ox.parse file_contents
        manifest.packages.locate("package").map do |dependency|
          Dependency.new(
            name: dependency.id,
            requirement: (dependency.version if dependency.respond_to? "version"),
            type: dependency.respond_to?("developmentDependency") && dependency.developmentDependency == "true" ? "development" : "runtime",
            source: options.fetch(:filename, nil)
          )
        end
      rescue StandardError
        []
      end

      def self.parse_csproj(file_contents, options: {})
        manifest = Ox.parse file_contents

        packages = manifest.locate("ItemGroup/PackageReference").select { |dep| dep.respond_to? "Include" }.map do |dependency|
          requirement = (dependency.Version if dependency.respond_to? "Version")
          if requirement.is_a?(Ox::Element)
            requirement = dependency.nodes.detect { |n| n.value == "Version" }&.text
          end

          type = if (dependency.nodes.first&.nodes&.include?("all") && dependency.nodes.first.value.include?("PrivateAssets")) || dependency.attributes[:PrivateAssets] == "All"
                   "development"
                 else
                   "runtime"
                 end

          Dependency.new(
            name: dependency.Include,
            requirement: requirement,
            type: type,
            source: options.fetch(:filename, nil)
          )
        end
        packages.uniq(&:name)
      rescue StandardError
        []
      end

      def self.parse_nuspec(file_contents, options: {})
        manifest = Ox.parse file_contents
        manifest.package.metadata.dependencies.locate("dependency").map do |dependency|
          Dependency.new(
            name: dependency.id,
            requirement: dependency.attributes[:version],
            type: dependency.respond_to?("developmentDependency") && dependency.developmentDependency == "true" ? "development" : "runtime",
            source: options.fetch(:filename, nil)
          )
        end
      rescue StandardError
        []
      end

      def self.parse_paket_lock(file_contents, options: {})
        lines = file_contents.split("\n")
        package_version_re = /\s+(?<name>\S+)\s\((?<version>\d+\.\d+[\.\d+[\.\d+]*]*)\)/
        packages = lines.select { |line| package_version_re.match(line) }.map { |line| package_version_re.match(line) }.map do |match|
          Dependency.new(
            name: match[:name].strip,
            requirement: match[:version],
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end
        # we only have to enforce uniqueness by name because paket ensures that there is only the single version globally in the project
        packages.uniq(&:name)
      end

      def self.parse_project_assets_json(file_contents, options: {})
        manifest = JSON.parse file_contents

        frameworks = {}
        manifest.fetch("targets", []).each do |framework, deps|
          frameworks[framework] = deps
            .select { |_name, details| details["type"] == "package" }
            .map do |name, _details|
              name_split = name.split("/")
              Dependency.new(
                name: name_split[0],
                requirement: name_split[1],
                type: "runtime",
                source: options.fetch(:filename, nil)
              )
            end
        end

        unless frameworks.empty?
          # we should really return multiple manifests, but bibliothecary doesn't
          # do that yet so at least pick deterministically.

          # Note, frameworks can be empty, so remove empty ones and then return the last sorted item if any
          frameworks = frameworks.delete_if { |_k, v| v.empty? }
          return frameworks[frameworks.keys.max] unless frameworks.empty?
        end
        []
      end
    end
  end
end
