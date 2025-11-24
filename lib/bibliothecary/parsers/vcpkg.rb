# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Vcpkg
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("vcpkg.json") => {
            kind: "manifest",
            parser: :parse_vcpkg_json,
          },
          # _generated-vcpkg-list.json is the output of `vcpkg list --x-json`.
          match_filename("_generated-vcpkg-list.json") => {
            kind: "lockfile",
            parser: :parse_vcpkg_list_json,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_vcpkg_json(file_contents, options: {})
        dependencies = []
        manifest = JSON.parse(file_contents)
        deps = manifest["dependencies"]

        if !deps || deps.empty?
          return ParserResult.new(dependencies: dependencies)
        end

        overrides = {}
        manifest["overrides"]&.each do |override|
          if override.is_a?(Hash) && override["name"]
            override_version = override["version"] || override["version-semver"] || override["version-date"] || override["version-string"]
            overrides[override["name"]] = format_requirement(override_version, override["port-version"])
          end
        end

        deps.each do |dep|
          if dep.is_a?(String)
            # Simple string format: "boost-system"
            name = dep
            requirement = nil
            is_development = false
          elsif dep.is_a?(Hash)
            # Object format: { "name": "cpprestsdk", "version>=": "2.10.0", ... }
            name = dep["name"]
            requirement = if dep["version>="]
                            ">=#{dep['version>=']}"
                          end
            is_development = dep["host"] == true
          end

          # Skip entries with no name
          next if name.nil? || name.empty?

          requirement = overrides[name] if overrides[name]

          dependencies << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: is_development ? "development" : "runtime",
            source: options.fetch(:filename, nil)
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_vcpkg_list_json(file_contents, options: {})
        # parses the output of `vcpkg list --x-json`
        dependencies = []
        manifest = JSON.parse(file_contents)

        manifest.each_value do |package_info|
          name = package_info["package_name"]
          version = package_info["version"]
          port_version = package_info["port_version"]

          # Skip entries with no name
          next if name.nil? || name.empty?

          dependencies << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: format_requirement(version, port_version),
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.format_requirement(version, port_version)
        return "*" unless version

        if port_version && port_version > 0
          return "#{version}##{port_version}"
        end

        version
      end
    end
  end
end
