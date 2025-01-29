require "yaml"
require "json"

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      GPM_REGEXP = /^(.+)\s+(.+)$/
      GOMOD_COMMENT_REGEXP = /(\/\/(.*))/
      GOMOD_REPLACEMENT_SEPARATOR_REGEXP = /\s=>\s/
      GOMOD_DEP_REGEXP = /(?<name>\S+)\s?(?<requirement>[^\s=>]+)?\s*(?<indirect>\/\/\s+indirect)?/ # the " =>" negative character class is to make sure we don't capture the delimiter for "replace" deps
      GOMOD_SINGLELINE_DEP_REGEXP = /^(?<category>require|exclude|replace|retract)\s+#{GOMOD_DEP_REGEXP}.*$/
      GOMOD_MULTILINE_DEP_REGEXP = /^#{GOMOD_DEP_REGEXP}.*$/
      GOMOD_MULTILINE_START_REGEXP = /^(?<category>require|exclude|replace|retract)\s+\(/
      GOMOD_MULTILINE_END_REGEXP = /^\)/
      GOSUM_REGEXP = /^(.+)\s+(.+)\s+(.+)$/

      def self.mapping
        {
          # Go Modules (recommended)
          match_filename("go.mod") => {
            kind: "manifest",
            parser: :parse_go_mod,
          },
          match_filename("go.sum") => {
            kind: "lockfile",
            parser: :parse_go_sum,
          },
          # Glide (unmaintained: https://github.com/Masterminds/glide#go-modules)
          match_filename("glide.yaml") => {
            kind: "manifest",
            parser: :parse_glide_yaml,
          },
          match_filename("glide.lock") => {
            kind: "lockfile",
            parser: :parse_glide_lockfile,
          },
          # Godep (unmaintained: https://github.com/tools/godep)
          match_filename("Godeps/Godeps.json") => {
            kind: "manifest",
            parser: :parse_godep_json,
          },
          match_filename("Godeps", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_gpm,
          },
          # Govendor (unmaintained: https://github.com/kardianos/govendor)
          match_filename("vendor/manifest") => {
            kind: "manifest",
            parser: :parse_gb_manifest,
          },
          match_filename("vendor/vendor.json") => {
            kind: "manifest",
            parser: :parse_govendor,
          },
          # Go dep (deprecated: https://github.com/golang/dep#dep)
          match_filename("Gopkg.toml") => {
            kind: "manifest",
            parser: :parse_dep_toml,
          },
          match_filename("Gopkg.lock") => {
            kind: "lockfile",
            parser: :parse_dep_lockfile,
          },
          match_filename("go-resolved-dependencies.json") => {
            kind: "lockfile",
            parser: :parse_go_resolved,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_godep_json(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = JSON.parse file_contents
        map_dependencies(manifest, "Deps", "ImportPath", "Rev", "runtime")
      end

      def self.parse_gpm(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        deps = []
        file_contents.split("\n").each do |line|
          match = line.gsub(/(\#(.*))/, "").match(GPM_REGEXP)
          next unless match
          deps << Dependency.new(
            name: match[1].strip,
            requirement: match[2].strip,
            type: "runtime",
          )
        end
        deps
      end

      def self.parse_govendor(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = JSON.load file_contents
        map_dependencies(manifest, "package", "path", "revision", "runtime")
      end

      def self.parse_glide_yaml(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = YAML.load file_contents
        map_dependencies(manifest, "import", "package", "version", "runtime") +
        map_dependencies(manifest, "devImports", "package", "version", "development")
      end

      def self.parse_glide_lockfile(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        # glide.lock files contain an "updated" Time field, but Ruby 3.2+ requires us to safelist that class
        manifest = YAML.load file_contents, permitted_classes: [Time]
        map_dependencies(manifest, "imports", "name", "version", "runtime")
      end

      def self.parse_gb_manifest(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = JSON.parse file_contents
        map_dependencies(manifest, "dependencies", "importpath", "revision", "runtime")
      end

      def self.parse_dep_toml(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = Tomlrb.parse file_contents
        map_dependencies(manifest, "constraint", "name", "version", "runtime")
      end

      def self.parse_dep_lockfile(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = Tomlrb.parse file_contents
        map_dependencies(manifest, "projects", "name", "revision", "runtime")
      end

      def self.parse_go_mod(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        categorized_deps = parse_go_mod_categorized_deps(file_contents)

        deps = categorized_deps["require"]
          .map do |dep|
            # NOTE: A "replace" directive doesn't add the dep to the module graph unless the original dep is also in a "require" directive,
            # so we need to track down replacements here and use those instead of the originals, if present.
            #
            # NOTE: The "replace" directive doesn't actually change the version reported from Go (e.g. "go mod graph"), it only changes
            # the *source code*. So by replacing the deps here, we're giving more honest results than you'd get when asking go
            # about the versions used.
            replaced_dep = categorized_deps["replace"]
              .find do |replacement_dep|
                replacement_dep.original_name == dep.name &&
                  (replacement_dep.original_requirement == "*" || replacement_dep.original_requirement == dep.requirement)
              end

            replaced_dep || dep
          end

        return deps
      end

      def self.parse_go_mod_categorized_deps(file_contents)
        current_multiline_category = nil
        # docs: https://go.dev/ref/mod#go-mod-file-require
        categorized_deps = {
          "require" => [],
          "exclude" => [], # these deps are not necessarily used by the module
          "replace" => [], # these deps are not necessarily used by the module
          "retract" => [], # TODO: these are not parsed correctly right now, but they shouldn't be returned in list of deps anyway.
        }
        file_contents
          .lines
          .map(&:strip)
          .reject { |line| line =~ /^#{GOMOD_COMMENT_REGEXP}/ } # ignore comment lines
          .each do |line|
            if line.match(GOMOD_MULTILINE_END_REGEXP) # detect the end of a multiline
              current_multiline_category = nil
            elsif (match = line.match(GOMOD_MULTILINE_START_REGEXP)) # or, detect the start of a multiline
              current_multiline_category = match[1]
            elsif (match = line.match(GOMOD_SINGLELINE_DEP_REGEXP)) # or, detect a singleline dep
              categorized_deps[match[:category]] << go_mod_category_relative_dep(category: match[:category], line: line, match: match)
            elsif (current_multiline_category && match = line.match(GOMOD_MULTILINE_DEP_REGEXP)) # otherwise, parse the multiline dep
              categorized_deps[current_multiline_category] << go_mod_category_relative_dep(category: current_multiline_category, line: line, match: match)
            end
          end
        categorized_deps
      end

      def self.parse_go_sum(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        deps = []
        file_contents.lines.map(&:strip).each do |line|
          if (match = line.match(GOSUM_REGEXP))
            deps << Dependency.new(
              name: match[1].strip,
              requirement: match[2].strip.split("/").first,
              type: "runtime",
            )
          end
        end
        deps.uniq
      end

      def self.parse_go_resolved(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        JSON.parse(file_contents)
          .select { |dep| dep["Main"] != "true" }
          .map do |dep|
            if dep["Replace"].is_a?(String) && dep["Replace"] != "<nil>" && dep["Replace"] != ""
              # NOTE: The "replace" directive doesn't actually change the version reported from Go (e.g. "go mod graph"), it only changes
              # the *source code*. So by replacing the deps here, we're giving more honest results than you'd get when asking go
              # about the versions used.
              name, requirement = dep["Replace"].split(" ", 2)
              requirement = "*" if requirement.to_s.strip == ""
              Dependency.new(
                name: name, requirement: requirement, original_name: dep["Path"], original_requirement: dep["Version"], type: dep.fetch("Scope") { "runtime" }
              )
            else
              Dependency.new(
                name: dep["Path"], requirement: dep["Version"], type: dep.fetch("Scope") { "runtime" }
              )
            end
          end
      end

      def self.map_dependencies(manifest, attr_name, dep_attr_name, version_attr_name, type)
        manifest.fetch(attr_name,[]).map do |dependency|
          Dependency.new(
            name: dependency[dep_attr_name],
            requirement: dependency[version_attr_name],
            type: type,
          )
        end
      end

      # Returns our standard-ish dep Hash based on the category of dep matched ("require", "replace", etc.)
      def self.go_mod_category_relative_dep(category:, line:, match:)
        case category
        when "replace"
          replacement_dep = line.split(GOMOD_REPLACEMENT_SEPARATOR_REGEXP, 2).last
          replacement_match = replacement_dep.match(GOMOD_DEP_REGEXP)
          Dependency.new(
            original_name: match[:name],
            original_requirement: match[:requirement],
            name: replacement_match[:name],
            requirement: replacement_match[:requirement],
            type: "runtime",
            direct: !match[:indirect],
          )
        when "retract"
          Dependency.new(
            name: match[:name],
            requirement: match[:requirement],
            type: "runtime",
            deprecated: true,
            direct: !match[:indirect],
          )
        else
          Dependency.new(
            name: match[:name],
            requirement: match[:requirement],
            type: "runtime",
            direct: !match[:indirect],
          )
        end
      end
    end
  end
end
