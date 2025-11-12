# frozen_string_literal: true

# Ported from Go code available at https://github.com/google/osv-scalibr/blob/f37275e81582aee924103d49d9a27c8e353477e7/extractor/filesystem/language/cpp/conanlock/conanlock.go
# Go code was made available under the Apache License, Version 2.0

module Bibliothecary
  module Parsers
    class Conan
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("conanfile.py") => {
            kind: "manifest",
            parser: :parse_conanfile_py,
          },
          match_filename("conanfile.txt") => {
            kind: "manifest",
            parser: :parse_conanfile_txt,
          },
          match_filename("conan.lock") => {
            kind: "lockfile",
            parser: :parse_lockfile,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_conanfile_py(file_contents, options: {})
        dependencies = []

        # Parse self.requires() calls in conanfile.py
        # Pattern matches: self.requires("package/version") or self.requires("package/version", force=True, options={...})
        # Captures only the package spec string; additional keyword arguments are ignored
        file_contents.scan(/self\.requires\(\s*["']([^"']+)["']/).each do |match|
          manifest_dep = match[0]
          reference = parse_conan_reference(manifest_dep)

          # Skip entries with no name
          next if reference[:name].nil? || reference[:name].empty?

          dependencies << Dependency.new(
            name: reference[:name],
            requirement: reference[:version],
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_conanfile_txt(file_contents, options: {})
        dependencies = []
        current_section = nil

        file_contents.each_line do |line|
          line = line.strip

          # Skip empty lines and comments
          next if line.empty? || line.start_with?("#")

          # Check for section headers
          if line.match?(/^\[([^\]]+)\]$/)
            current_section = line[1..-2]
            next
          end

          # Parse dependencies in [requires] and [build_requires] sections
          next unless %w[requires build_requires].include?(current_section)

          reference = parse_conan_reference(manifest_dep)
          next if reference[:name].nil? || reference[:name].empty?

          dependencies << Dependency.new(
            name: reference[:name],
            requirement: reference[:version],
            type: current_section == "requires" ? "runtime" : "development",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_lockfile(file_contents, options: {})
        manifest = JSON.parse(file_contents)

        # Auto-detect lockfile format version
        if manifest.dig("graph_lock", "nodes")
          parse_v1_lockfile(manifest, options: options)
        else
          parse_v2_lockfile(manifest, options: options)
        end
      end

      def self.parse_v1_lockfile(lockfile, options: {})
        dependencies = []

        lockfile["graph_lock"]["nodes"].each_value do |node|
          if node["path"] && !node["path"].empty?
            # a local "conanfile.txt", skip
            next
          end

          reference = nil
          if node["pref"]
            #  old format 0.3 (conan 1.27-) lockfiles use "pref" instead of "ref"
            reference = parse_conan_reference(node["pref"])
          elsif node["ref"]
            reference = parse_conan_reference(node["ref"])
          else
            next
          end

          # skip entries with no name, they are most likely consumer's conanfiles
          # and not dependencies to be searched in a database anyway
          next if reference[:name].nil? || reference[:name].empty?

          type = case node["context"]
                 when "build"
                   "development"
                 else
                   "runtime"
                 end

          dependencies << Dependency.new(
            name: reference[:name],
            requirement: reference[:version],
            type: type,
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_v2_lockfile(lockfile, options: {})
        dependencies = []

        parse_conan_requires(dependencies, lockfile["requires"], "runtime", options)
        parse_conan_requires(dependencies, lockfile["build_requires"], "development", options)
        parse_conan_requires(dependencies, lockfile["python_requires"], "development", options)

        ParserResult.new(dependencies: dependencies)
      end

      # Helper method to parse an array of Conan package references
      # Similar to OSV Scalibr's parseConanRequires function
      def self.parse_conan_requires(dependencies, requires, type, options)
        return unless requires && !requires.empty?

        requires.each do |ref|
          reference = parse_conan_reference(ref)

          # Skip entries with no name, they are most likely consumer's conanfiles
          # and not dependencies to be searched in a database anyway
          next if reference[:name].nil? || reference[:name].empty?

          dependencies << Dependency.new(
            name: reference[:name],
            requirement: reference[:version] || "*",
            type: type,
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
      end

      # Parse Conan reference
      # Handles the full Conan reference format:
      # name/version[@username[/channel]][#recipe_revision][:package_id[#package_revision]][%timestamp]
      #
      # Based on OSV Scalibr's parseConanReference implementation:
      # https://github.com/google/osv-scalibr/blob/f37275e81582aee924103d49d9a27c8e353477e7/extractor/filesystem/language/cpp/conanlock/conanlock.go
      #
      # Returns a hash with keys: name, version, username, channel, recipe_revision, package_id, package_revision, timestamp
      def self.parse_conan_reference(ref)
        reference = {
          name: nil,
          version: nil,
          username: nil,
          channel: nil,
          recipe_revision: nil,
          package_id: nil,
          package_revision: nil,
          timestamp: nil,
        }

        return reference if ref.nil? || ref.empty?

        # Validate that ref contains "/" (name/version format)
        # This filters out invalid entries like "1.2.3" (version without name)
        return reference unless ref.include?("/")

        # Strip timestamp: name/version%1234 -> name/version
        parts = ref.split("%", 2)
        if parts.length == 2
          ref = parts[0]
          reference[:timestamp] = parts[1]
        end

        # Strip package revision: name/version:pkgid#prev -> name/version
        parts = ref.split(":", 2)
        if parts.length == 2
          ref = parts[0]
          pkg_parts = parts[1].split("#", 2)
          reference[:package_id] = pkg_parts[0]
          reference[:package_revision] = pkg_parts[1] if pkg_parts.length == 2
        end

        # Strip recipe revision: name/version#rrev -> name/version
        parts = ref.split("#", 2)
        if parts.length == 2
          ref = parts[0]
          reference[:recipe_revision] = parts[1]
        end

        # Strip username/channel: name/version@user/channel -> name/version
        parts = ref.split("@", 2)
        if parts.length == 2
          ref = parts[0]
          user_channel = parts[1].split("/", 2)
          reference[:username] = user_channel[0]
          reference[:channel] = user_channel[1] if user_channel.length == 2
        end

        # Split name/version: name/version -> [name, version]
        parts = ref.split("/", 2)
        reference[:name] = parts[0]
        reference[:version] = parts.length == 2 ? parts[1] : nil

        reference
      end
    end
  end
end
