# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      # Max depth to recurse into the "dependencies" property of package-lock.json
      PACKAGE_LOCK_JSON_MAX_DEPTH = 10

      def self.mapping
        {
          match_filename("package.json") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
          match_filename("npm-shrinkwrap.json") => {
            kind: "lockfile",
            parser: :parse_shrinkwrap,
          },
          match_filename("yarn.lock") => {
            kind: "lockfile",
            parser: :parse_yarn_lock,
          },
          match_filename("package-lock.json") => {
            kind: "lockfile",
            parser: :parse_package_lock,
          },
          match_filename("npm-ls.json") => {
            kind: "lockfile",
            parser: :parse_ls,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_package_lock(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        # https://docs.npmjs.com/cli/v9/configuring-npm/package-lock-json#lockfileversion
        if manifest["lockfileVersion"].to_i <= 1
          # lockfileVersion 1 uses the "dependencies" object
          parse_package_lock_v1(manifest, options.fetch(:filename, nil))
        else
          # lockfileVersion 2 has backwards-compatability by including both "packages" and the legacy "dependencies" object
          # lockfileVersion 3 has no backwards-compatibility and only includes the "packages" object
          parse_package_lock_v2(manifest, options.fetch(:filename, nil))
        end
      end

      class << self
        # "package-lock.json" and "npm-shrinkwrap.json" have same format, so use same parsing logic
        alias parse_shrinkwrap parse_package_lock
      end

      def self.parse_package_lock_v1(manifest, source = nil)
        parse_package_lock_deps_recursively(manifest.fetch("dependencies", []), source)
      end

      def self.parse_package_lock_v2(manifest, source = nil)
        # "packages" is a flat object where each key is the installed location of the dep, e.g. node_modules/foo/node_modules/bar.
        manifest
          .fetch("packages")
          # there are a couple of scenarios where a package's name won't start with node_modules
          #   1. name == "", this is the lockfile's package itself
          #   2. when a package is a local path dependency, it will appear in package-lock.json twice.
          #      * One occurrence has the node_modules/ prefix in the name (which we keep)
          #      * The other occurrence's name is the path to the local dependency (which has less information, and is duplicative, so we discard)
          .select { |name, _dep| name.start_with?("node_modules") }
          .map do |name, dep|
            Dependency.new(
              name: name.split("node_modules/").last,
              requirement: dep["version"],
              type: dep.fetch("dev", false) || dep.fetch("devOptional", false) ? "development" : "runtime",
              local: dep.fetch("link", false),
              source: source
            )
          end
      end

      def self.parse_package_lock_deps_recursively(dependencies, source = nil, depth = 1)
        dependencies.flat_map do |name, requirement|
          type = requirement.fetch("dev", false) ? "development" : "runtime"
          version = requirement.key?("from") ? requirement["from"][/#(?:semver:)?v?(.*)/, 1] : nil
          version ||= requirement["version"].split("#").last
          child_dependencies = if depth >= PACKAGE_LOCK_JSON_MAX_DEPTH
                                 []
                               else
                                 parse_package_lock_deps_recursively(requirement.fetch("dependencies", []), source, depth + 1)
                               end

          [Dependency.new(
            name: name,
            requirement: version,
            type: type,
            source: source,
          )] + child_dependencies
        end
      end

      def self.parse_manifest(file_contents, options: {})
        # on ruby 3.2 we suddenly get this JSON error, so detect and return early: "package.json: unexpected token at ''"
        return [] if file_contents.empty?

        manifest = JSON.parse(file_contents)

        raise "appears to be a lockfile rather than manifest format" if manifest.key?("lockfileVersion")

        dependencies = manifest.fetch("dependencies", [])
          .reject { |name, _requirement| name.start_with?("//") } # Omit comment keys. They are valid in package.json: https://groups.google.com/g/nodejs/c/NmL7jdeuw0M/m/yTqI05DRQrIJ
          .map do |name, requirement|
            Dependency.new(
              name: name,
              requirement: requirement,
              type: "runtime",
              local: requirement.start_with?("file:"),
              source: options.fetch(:filename, nil)
            )
          end

        dependencies += manifest.fetch("devDependencies", [])
          .reject { |name, _requirement| name.start_with?("//") } # Omit comment keys. They are valid in package.json: https://groups.google.com/g/nodejs/c/NmL7jdeuw0M/m/yTqI05DRQrIJ
          .map do |name, requirement|
            Dependency.new(
              name: name,
              requirement: requirement,
              type: "development",
              local: requirement.start_with?("file:"),
              source: options.fetch(:filename, nil)
            )
          end

        dependencies
      end

      def self.parse_yarn_lock(file_contents, options: {})
        dep_hash = if file_contents.match(/__metadata:/)
                     parse_v2_yarn_lock(file_contents, options.fetch(:filename, nil))
                   else
                     parse_v1_yarn_lock(file_contents, options.fetch(:filename, nil))
                   end

        dep_hash.map do |dep|
          Dependency.new(
            name: dep[:name],
            requirement: dep[:version],
            type: "runtime", # lockfile doesn't tell us more about the type of dep
            local: dep[:requirements]&.first&.start_with?("file:"),
            source: options.fetch(:filename, nil)
          )
        end
      end

      # Returns a hash representation of the deps in yarn.lock, eg:
      # [{
      #   name: "foo",
      #   requirements: [["foo", "^1.0.0"], ["foo", "^1.0.1"]],
      #   version: "1.2.0",
      # }, ...]
      def self.parse_v1_yarn_lock(contents, source = nil)
        contents
          .gsub(/^#.*/, "")
          .strip
          .split("\n\n")
          .map do |chunk|
            requirements = chunk
              .lines
              .find { |l| !l.start_with?(" ") && l.strip.end_with?(":") } # first line, eg: '"@bar/foo@1.0.0", "@bar/foo@^1.0.1":'
              .strip
              .gsub(/"|:$/, "") # don't need quotes or trailing colon
              .split(",") # split the list of requirements
              .map { |d| d.strip.split(/(?<!^)@/, 2) } # split each requirement on name/version "@"", not on leading namespace "@"
            version = chunk.match(/version "?([^"]*)"?/)[1]

            {
              name: requirements.first.first,
              requirements: requirements.map { |x| x[1] },
              version: version,
              source: source,
            }
          end
      end

      def self.parse_v2_yarn_lock(contents, source = nil)
        parsed = YAML.load(contents)
        parsed = parsed.except("__metadata")
        parsed
          .reject do |packages, info|
            # yarn v4+ creates a lockfile entry: "myproject@workspace" with a "use.local" version
            #   this lockfile entry is a reference to the project to which the lockfile belongs
            # skip this self-referential package
            info["version"].to_s.include?("use.local") && packages.include?("workspace")
          end
          .map do |packages, info|
            packages = packages.split(", ")
            # use first requirement's name, assuming that deps will always resolve from deps of the same name
            name = packages.first.rpartition("@").first
            requirements = packages.map { |p| p.rpartition("@").last.gsub(/^.*:/, "") }

            {
              name: name,
              requirements: requirements,
              version: info["version"].to_s,
              source: source,
            }
          end
      end

      def self.parse_ls(file_contents, options: {})
        manifest = JSON.parse(file_contents)

        transform_tree_to_array(manifest.fetch("dependencies", {}), options.fetch(:filename, nil))
      end

      def self.lockfile_preference_order(file_infos)
        files = file_infos.each_with_object({}) do |file_info, obj|
          obj[File.basename(file_info.full_path)] = file_info
        end

        if files["npm-shrinkwrap.json"]
          [files["npm-shrinkwrap.json"]] + files.values.reject { |fi| File.basename(fi.full_path) == "npm-shrinkwrap.json" }
        else
          files.values
        end
      end

      private_class_method def self.transform_tree_to_array(deps_by_name, source = nil)
        deps_by_name.map do |name, metadata|
          [
            Dependency.new(
              name: name,
              requirement: metadata["version"],
              type: "runtime",
              source: source
            ),
          ] + transform_tree_to_array(metadata.fetch("dependencies", {}), source)
        end.flatten(1)
      end
    end
  end
end
