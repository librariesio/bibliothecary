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
          match_filename("yarn.lock") => {
            kind: "lockfile",
            parser: :parse_yarn_lock,
          },
          match_filename("package-lock.json") => {
            kind: "lockfile",
            parser: :parse_package_lock,
          },
          match_filename("pnpm-lock.yaml") => {
            kind: "lockfile",
            parser: :parse_pnpm_lock,
          },
          match_filename("npm-ls.json") => {
            kind: "lockfile",
            parser: :parse_ls,
          },
          match_filename("npm-shrinkwrap.json") => {
            kind: "lockfile",
            parser: :parse_shrinkwrap,
          },
          match_filename("bun.lock") => {
            kind: "lockfile",
            parser: :parse_bun_lock,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_package_lock(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        # https://docs.npmjs.com/cli/v9/configuring-npm/package-lock-json#lockfileversion
        dependencies = if manifest["lockfileVersion"].to_i <= 1
                         # lockfileVersion 1 uses the "dependencies" object
                         parse_package_lock_v1(manifest, options.fetch(:filename, nil))
                       else
                         # lockfileVersion 2 has backwards-compatability by including both "packages" and the legacy "dependencies" object
                         # lockfileVersion 3 has no backwards-compatibility and only includes the "packages" object
                         parse_package_lock_v2(manifest, options.fetch(:filename, nil))
                       end
        ParserResult.new(dependencies: dependencies)
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
            # check if the name property is available and differs from the node modules location
            # this indicates that the package has been aliased
            node_module_name = name.split("node_modules/").last
            name_property = dep["name"]
            if !name_property.nil? && node_module_name != name_property
              name = name_property
              original_name = node_module_name
            else
              name = node_module_name
            end

            Dependency.new(
              name: name,
              original_name: original_name,
              requirement: dep["version"],
              original_requirement: original_name.nil? ? nil : dep["version"],
              type: dep.fetch("dev", false) || dep.fetch("devOptional", false) ? "development" : "runtime",
              local: dep.fetch("link", false),
              source: source,
              platform: platform_name
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
            platform: platform_name
          )] + child_dependencies
        end
      end

      def self.parse_manifest(file_contents, options: {})
        # on ruby 3.2 we suddenly get this JSON error, so detect and return early: "package.json: unexpected token at ''"
        return ParserResult.new(dependencies: []) if file_contents.empty?

        manifest = JSON.parse(file_contents)

        raise "appears to be a lockfile rather than manifest format" if manifest.key?("lockfileVersion")

        dependencies = manifest.fetch("dependencies", [])
          .reject { |name, _requirement| name.start_with?("//") } # Omit comment keys. They are valid in package.json: https://groups.google.com/g/nodejs/c/NmL7jdeuw0M/m/yTqI05DRQrIJ
          .map do |name, requirement|
            # check to see if this is an aliased package name
            # example: "alias-package-name": "npm:actual-package@^1.1.3"
            if requirement.include?("npm:")
              # the name of the real dependency is contained in the requirement with the version
              requirement.gsub!("npm:", "")
              original_name = name
              name, _, requirement = requirement.rpartition("@")
            end

            Dependency.new(
              name: name,
              original_name: original_name,
              requirement: requirement,
              original_requirement: original_name.nil? ? nil : requirement,
              type: "runtime",
              local: requirement.start_with?("file:"),
              source: options.fetch(:filename, nil),
              platform: platform_name
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
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_yarn_lock(file_contents, options: {})
        dep_hash = if file_contents.match(/__metadata:/)
                     parse_v2_yarn_lock(file_contents, options.fetch(:filename, nil))
                   else
                     parse_v1_yarn_lock(file_contents, options.fetch(:filename, nil))
                   end

        dependencies = dep_hash.map do |dep|
          Dependency.new(
            name: dep[:name],
            original_name: dep[:original_name],
            requirement: dep[:version],
            original_requirement: dep[:original_requirement],
            type: nil, # yarn.lock doesn't report on the type of dependency
            local: dep[:requirements]&.first&.start_with?("file:"),
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: dependencies)
      end

      # Returns a hash representation of the deps in yarn.lock, eg:
      # [{
      #   name: "foo",
      #   requirements: [["foo", "^1.0.0"], ["foo", "^1.0.1"]],
      #   version: "1.2.0",
      # }, ...]
      def self.parse_v1_yarn_lock(contents, source = nil)
        contents
          .encode(universal_newline: true)
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

            name, alias_name = yarn_strip_npm_protocol(requirements.first) # if a package is aliased, strip the alias and return the real package name
            name = name.strip.split(/(?<!^)@/).first
            requirements = requirements.map { |d| d.strip.split(/(?<!^)@/, 2) } # split each requirement on name/version "@"", not on leading namespace "@"
            version = chunk.match(/version "?([^"]*)"?/)[1]

            {
              name: name,
              original_name: alias_name,
              requirements: requirements.map { |x| x[1] },
              original_requirement: alias_name.nil? ? nil : version,
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
            (info["version"].to_s.include?("use.local") && packages.include?("workspace")) ||
              # yarn allows users to insert patches to their dependencies from within their project
              # these patches are marked as a separate entry in the lock file but do not represent a new dependency
              # and should be skipped here
              # https://yarnpkg.com/protocol/patch
              packages.include?("@patch:")
          end
          .map do |packages, info|
            packages = packages.split(", ")
            # use first requirement's name, assuming that deps will always resolve from deps of the same name
            name, alias_name = yarn_strip_npm_protocol(packages.first.rpartition("@").first)
            requirements = packages.map { |p| p.rpartition("@").last.gsub(/^.*:/, "") }

            {
              name: name,
              original_name: alias_name,
              requirements: requirements,
              original_requirement: alias_name.nil? ? nil : info["version"].to_s,
              version: info["version"].to_s,
              source: source,
            }
          end
      end

      def self.parse_v5_pnpm_lock(parsed_contents, source = nil)
        dependency_mapping = parsed_contents.fetch("dependencies", {})
          .merge(parsed_contents.fetch("devDependencies", {}))

        parsed_contents["packages"]
          .map do |name_version, details|
            # e.g. "/debug/2.6.9" or "/@babel/types/7.28.1"
            name, _slash, version = name_version.sub(/^\//, "").rpartition("/")

            # e.g. "/debug/2.2.0_supports-color@1.2.0:"
            version = version.split("_", 2)[0]

            # e.g. "alias-package: /zod/3.24.2"
            original_name = nil
            original_requirement = nil
            if (alias_dep = dependency_mapping.find { |_n, v| v.start_with?("/#{name}/") })
              original_name = alias_dep[0]
              original_requirement = alias_dep[1].split("/", 3)[2] # e.g. "/zod/3.24.2"
            end

            is_dev = details["dev"] == true

            Dependency.new(
              name: name,
              requirement: version,
              original_name: original_name,
              original_requirement: original_requirement,
              type: is_dev ? "development" : "runtime",
              source: source,
              platform: platform_name
            )
          end
      end

      def self.parse_v6_pnpm_lock(parsed_contents, source = nil)
        dependency_mapping = parsed_contents.fetch("dependencies", {})
          .merge(parsed_contents.fetch("devDependencies", {}))

        parsed_contents["packages"]
          .map do |name_version, details|
            # e.g. "/debug@2.6.9:"
            name, version = name_version.sub(/^\//, "").split(/(?<!^)@/, 2)

            # e.g. "debug@2.2.0(supports-color@1.2.0)"
            version = version.split("(", 2).first

            # e.g.
            #  alias-package:
            #    specifier: npm:zod
            #    version: /zod@3.24.2
            original_name = nil
            original_requirement = nil
            if (alias_dep = dependency_mapping.find { |_n, info| info["specifier"] == "npm:#{name}" })
              original_name = alias_dep[0]
              original_requirement = alias_dep[1]["version"].sub(/^\//, "").split("@", 2)[1]
            end

            is_dev = details["dev"] == true

            Dependency.new(
              name: name,
              requirement: version,
              original_name: original_name,
              original_requirement: original_requirement,
              type: is_dev ? "development" : "runtime",
              source: source,
              platform: platform_name
            )
          end
      end

      def self.parse_v9_pnpm_lock(parsed_contents, source = nil)
        dependencies = parsed_contents.fetch("importers", {}).fetch(".", {}).fetch("dependencies", {})
        dev_dependencies = parsed_contents.fetch("importers", {}).fetch(".", {}).fetch("devDependencies", {})
        dependency_mapping = dependencies.merge(dev_dependencies)

        # "dependencies" is in "packages" for < v9 and in "snapshots" for >= v9
        # as of https://github.com/pnpm/pnpm/pull/7700.
        parsed_contents["snapshots"]
          .map do |name_version, _details|
            # e.g. "debug@2.6.9" or "@babel/types@7.28.1"
            name, version = name_version.split(/(?<!^)@/, 2)

            # e.g. "debug@2.2.0(supports-color@1.2.0)"
            version = version.split("(", 2).first

            # e.g.
            #  alias-package:
            #    specifier: npm:zod
            #    version: zod@3.24.2
            original_name = nil
            original_requirement = nil
            if (alias_dep = dependency_mapping.find { |_n, info| info["specifier"] == "npm:#{name}" })
              original_name = alias_dep[0]
              original_requirement = alias_dep[1]["version"].split("@", 2)[1]
            end

            # TODO: the "dev" field was removed in v9 lockfiles (https://github.com/pnpm/pnpm/pull/7808)
            # The proper way to set this for v9+ is to build a lookup of deps to
            # their "dependencies", and then recurse through each package's
            # parents. If the direct dep(s) that required them are all
            # "devDependencies" then we can consider them "dev == true". This
            # should be done using a DAG data structure, though, to be efficient
            # and avoid cycles.
            is_dev ||= dev_dependencies.any? do |dev_name, dev_details|
              dev_name == name && dev_details["version"] == version
            end

            Dependency.new(
              name: name,
              requirement: version,
              original_name: original_name,
              original_requirement: original_requirement,
              type: is_dev ? "development" : "runtime",
              source: source,
              platform: platform_name
            )
          end
      end

      # This method currently has been tested to support:
      #   lockfileVersion: '9.0'
      #   lockfileVersion: '6.0'
      #   lockfileVersion: '5.4'
      def self.parse_pnpm_lock(contents, options: {})
        parsed = YAML.load(contents)
        lockfile_version = parsed["lockfileVersion"].to_i

        dependencies = case lockfile_version
                       when 5
                         parse_v5_pnpm_lock(parsed, options.fetch(:filename, nil))
                       when 6
                         parse_v6_pnpm_lock(parsed, options.fetch(:filename, nil))
                       else # v9+
                         parse_v9_pnpm_lock(parsed, options.fetch(:filename, nil))
                       end
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_ls(file_contents, options: {})
        manifest = JSON.parse(file_contents)

        dependencies = transform_tree_to_array(manifest.fetch("dependencies", {}), options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_bun_lock(file_contents, options: {})
        # The stdlib JSON gem 2.8+ supports trailing commas.
        # The Oj gem does not support them as of writing, and will override
        # JSON.parse() if Oj.mimic_json/optimize_rails has been called. Luckily
        # JSON.parser is not overridden by Oj, so use it to call parse directly.
        manifest = JSON.parser.parse(file_contents, allow_trailing_comma: true)
        source = options.fetch(:filename, nil)

        dev_deps = manifest.dig("workspaces", "", "devDependencies")&.keys&.to_set

        dependencies = manifest.fetch("packages", []).map do |name, info|
          info_name, _, version = info.first.rpartition("@")
          is_local = version&.start_with?("file:")
          is_alias = info_name != name

          Dependency.new(
            name: info_name,
            original_name: is_alias ? name : nil,
            requirement: version,
            original_requirement: is_alias ? version : nil,
            type: dev_deps&.include?(name) ? "development" : "runtime",
            local: is_local,
            source: source,
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: dependencies)
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
              source: source,
              platform: platform_name
            ),
          ] + transform_tree_to_array(metadata.fetch("dependencies", {}), source)
        end.flatten(1)
      end

      # Yarn package names can be aliased by using the NPM protocol. If a package name includes
      # the NPM protocol then the name following the @npm: protocol identifier is the name of the
      # actual package being imported into the project under a different alias.
      # https://classic.yarnpkg.com/lang/en/docs/cli/add/#toc-yarn-add-alias
      private_class_method def self.yarn_strip_npm_protocol(dep_name)
        if dep_name.include?("@npm:")
          partitions = dep_name.rpartition("@npm:")
          alias_name = partitions.first
          dep_name = partitions.last
        end

        [dep_name, alias_name]
      end
    end
  end
end
