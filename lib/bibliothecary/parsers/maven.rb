# frozen_string_literal: true

require "ox"

# Known shortcomings and unimplemented Maven features:
#   pom.xml
#     <exclusions> cannot be taken into account (because it requires knowledge of transitive deps)
#     <properties> are the only thing inherited from parent poms currenly
module Bibliothecary
  module Parsers
    class Maven
      include Bibliothecary::Analyser

      # Matches digraph contents from the Maven dependency tree .dot file format.
      MAVEN_DOT_PROJECT_REGEXP = /digraph\s+"([^"]+)"\s+{/
      MAVEN_DOT_RELATIONSHIP_REGEXP = /"([^"]+)"\s+->\s+"([^"]+)"/

      # e.g. "annotationProcessor - Annotation processors and their dependencies for source set 'main'."
      GRADLE_TYPE_REGEXP = /^(\w+)/

      # e.g. "|    \\--- com.google.guava:guava:23.5-jre (*)"
      GRADLE_DEP_REGEXP = /(\+---|\\---){1}/

      # Dependencies that are on-disk projects, eg:
      # e.g. "\--- project :api:my-internal-project"
      # e.g. "+--- my-group:my-alias:1.2.3 -> project :client (*)"
      GRADLE_PROJECT_REGEXP = /project :(\S+)?/

      # line ending legend: (c) means a dependency constraint, (n) means not resolved, or (*) means resolved previously, e.g. org.springframework.boot:spring-boot-starter-web:2.1.0.M3 (*)
      # e.g. the "(n)" in "+--- my-group:my-name:1.2.3 (n)"
      GRADLE_LINE_ENDING_REGEXP = /(\((c|n|\*)\))$/

      # Builtin methods: https://docs.gradle.org/current/userguide/java_plugin.html#tab:configurations
      # Deprecated methods: https://docs.gradle.org/current/userguide/upgrading_version_6.html#sec:configuration_removal
      GRADLE_DEPENDENCY_METHODS = %w[api compile compileClasspath compileOnly compileOnlyApi implementation runtime runtimeClasspath runtimeOnly testCompile testCompileOnly testImplementation testRuntime testRuntimeOnly].freeze

      # Intentionally overly-simplified regexes to scrape deps from build.gradle (Groovy) and build.gradle.kts (Kotlin) files.
      # To be truly useful bibliothecary would need full Groovy / Kotlin parsers that speaks Gradle,
      # because the Groovy and Kotlin DSLs have many dynamic ways of declaring dependencies.
      GRADLE_VERSION_REGEXP = /[\w.-]+/ # e.g. '1.2.3'
      GRADLE_VAR_INTERPOLATION_REGEXP = /\$\w+/ # e.g. '$myVersion'
      GRADLE_CODE_INTERPOLATION_REGEXP = /\$\{.*\}/ # e.g. '${my-project-settings["version"]}'
      GRADLE_GAV_REGEXP = /([\w.-]+):([\w.-]+)(?::(#{GRADLE_VERSION_REGEXP}|#{GRADLE_VAR_INTERPOLATION_REGEXP}|#{GRADLE_CODE_INTERPOLATION_REGEXP}))?/ # e.g. "group:artifactId:1.2.3"
      GRADLE_GROOVY_SIMPLE_REGEXP = /(#{GRADLE_DEPENDENCY_METHODS.join('|')})\s*\(?\s*['"]#{GRADLE_GAV_REGEXP}['"]/m
      GRADLE_KOTLIN_SIMPLE_REGEXP = /(#{GRADLE_DEPENDENCY_METHODS.join('|')})\s*\(\s*"#{GRADLE_GAV_REGEXP}"/m

      MAVEN_PROPERTY_REGEXP = /\$\{(.+?)\}/
      MAX_DEPTH = 5

      # e.g. "[info]  test:"
      SBT_TYPE_REGEXP = /^\[info\]\s+([-\w]+):$/

      # e.g. "[info]  org.typelevel:spire-util_2.12"
      SBT_DEP_REGEXP = /^\[info\]\s+(.+)$/

      # e.g. "[info] 		- 1.7.5"
      SBT_VERSION_REGEXP = /^\[info\]\s+-\s+(.+)$/

      # e.g. "[info] 			homepage: http://www.slf4j.org"
      SBT_FIELD_REGEXP = /^\[info\]\s+([^:]+):\s+(.+)$/

      # e.g. "[info]  "
      SBT_IGNORE_REGEXP = /^\[info\]\s*$/

      # Copied from the "strings-ansi" gem, because it seems abandoned: https://github.com/piotrmurach/strings-ansi/pull/2
      # From: https://github.com/piotrmurach/strings-ansi/blob/35d0c9430cf0a8022dc12bdab005bce296cb9f00/lib/strings/ansi.rb#L14-L29
      # License: MIT
      # The regex to match ANSI codes
      ANSI_MATCHER = %r{
        (?>\033(
          \[[\[?>!]?\d*(;\d+)*[ ]?[a-zA-Z~@$^\]_\{\\] # graphics
          |
          \#?\d # cursor modes
          |
          [)(%+\-*/. ](\d|[a-zA-Z@=%]|) # character sets
          |
          O[p-xA-Z] # special keys
          |
          [a-zA-Z=><~\}|] # cursor movement
          |
          \]8;[^;]*;.*?(\033\\|\07) # hyperlink
        ))
      }x

      def self.mapping
        {
          match_filename("ivy.xml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_ivy_manifest,
          },
          match_filename("pom.xml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_standalone_pom_manifest,
          },
          match_filename("build.gradle", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_gradle,
          },
          match_filename("build.gradle.kts", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_gradle_kts,
          },
          match_extension(".xml", case_insensitive: true) => {
            content_matcher: :ivy_report?,
            kind: "lockfile",
            parser: :parse_ivy_report,
          },
          match_filename("gradle-dependencies-q.txt", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_gradle_resolved,
          },
          match_filename("maven-resolved-dependencies.txt", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_maven_resolved,
          },
          match_filename("sbt-update-full.txt", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_sbt_update_full,
          },
          # maven-dependency-tree.txt is the output of `mvn dependency:tree` as a single command.
          # The tree lines contain "[INFO]" prefix and uses 2-space indentation.
          match_filename("maven-dependency-tree.txt", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_maven_tree,
          },
          # maven-dependency-tree.dot is the output of this command:
          # `mvn dependency:tree -DoutputType=dot -DoutputFile=maven-dependency-tree.dot`
          # It doesn't have the "[INFO]" prefix, and is in graphviz .dot format.
          match_filename("maven-dependency-tree.dot", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_maven_tree_dot,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_ivy_manifest(file_contents, options: {})
        manifest = Ox.parse file_contents
        dependencies = manifest.dependencies.locate("dependency").map do |dependency|
          attrs = dependency.attributes
          Dependency.new(
            name: "#{attrs[:org]}:#{attrs[:name]}",
            requirement: attrs[:rev],
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: dependencies)
      end

      def self.ivy_report?(file_contents)
        doc = Ox.parse file_contents
        root = doc&.locate("ivy-report")&.first
        !root.nil?
      rescue Exception # rubocop:disable Lint/RescueException
        # We rescue exception here since native libs can throw a non-StandardError
        # We don't want to throw errors during the matching phase, only during
        # parsing after we match.
        false
      end

      def self.parse_ivy_report(file_contents, options: {})
        doc = Ox.parse file_contents
        root = doc.locate("ivy-report").first
        raise "ivy-report document does not have ivy-report at the root" if root.nil?

        info = doc.locate("ivy-report/info").first
        raise "ivy-report document lacks <info> element" if info.nil?

        type = info.attributes[:conf]
        type = "unknown" if type.nil?
        modules = doc.locate("ivy-report/dependencies/module")
        dependencies = modules.map do |mod|
          attrs = mod.attributes
          org = attrs[:organisation]
          name = attrs[:name]
          version = mod.locate("revision").first&.attributes&.[](:name)

          next nil if org.nil? || name.nil? || version.nil?

          Dependency.new(
            name: "#{org}:#{name}",
            requirement: version,
            type: type,
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end.compact
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_gradle_resolved(file_contents, options: {})
        current_type = nil

        dependencies = file_contents.split("\n").map do |line|
          current_type_match = GRADLE_TYPE_REGEXP.match(line)
          current_type = current_type_match.captures[0] if current_type_match

          gradle_dep_match = GRADLE_DEP_REGEXP.match(line)
          next unless gradle_dep_match

          split = gradle_dep_match.captures[0]

          # gradle can import on-disk projects and deps will be listed under them, e.g. `+--- project :test:integration`,
          # so we treat these projects as "internal" deps with requirement of "1.0.0"
          if (project_match = line.match(GRADLE_PROJECT_REGEXP))
            # an empty project name is self-referential (i.e. a cycle), and we don't need to track the manifest's project itself, e.g. "+--- project :"
            next if project_match[1].nil?

            # project names can have colons (e.g. for gradle projects in subfolders), which breaks maven artifact naming assumptions, so just replace them with hyphens.
            project_name = project_match[1].gsub(":", "-")
            line = line.sub(GRADLE_PROJECT_REGEXP, "internal:#{project_name}:1.0.0")
          end

          dep = line
            .split(split)[1]
            .sub(GRADLE_LINE_ENDING_REGEXP, "")
            .sub(/ FAILED$/, "") # dependency could not be resolved (but still may have a version)
            .sub(" -> ", ":") # handle version arrow syntax
            .strip
            .split(":")

          # A testImplementation line can look like this so just skip those
          # \--- org.springframework.security:spring-security-test (n)
          next unless dep.length >= 3

          if dep.count == 6
            # get name from renamed package resolution "org:name:version -> renamed_org:name:version"
            Dependency.new(
              original_name: dep[0, 2].join(":"),
              original_requirement: dep[2],
              name: dep[-3..-2].join(":"),
              requirement: dep[-1],
              type: current_type,
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          elsif dep.count == 5
            # get name from renamed package resolution "org:name -> renamed_org:name:version"
            Dependency.new(
              original_name: dep[0, 2].join(":"),
              original_requirement: "*",
              name: dep[-3..-2].join(":"),
              requirement: dep[-1],
              type: current_type,
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          else
            # get name from version conflict resolution ("org:name:version -> version") and no-resolution ("org:name:version")
            Dependency.new(
              name: dep[0..1].join(":"),
              requirement: dep[-1],
              type: current_type,
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          end
        end
          .compact
          .uniq { |item| [item.name, item.requirement, item.type, item.original_name, item.original_requirement] }
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_maven_resolved(file_contents, options: {})
        dependencies = file_contents
          .gsub(ANSI_MATCHER, "")
          .split("\n")
          .map { |line| parse_resolved_dep_line(line, options: options) }
          .compact
          .uniq
        ParserResult.new(dependencies: dependencies)
      end

      # Return each item in the ascii art tree with a depth of that item,
      # like [[0, "groupId:artifactId:jar:version:scope"], [1, "..."], ...]
      # The depth-0 items are the (sub)project names
      # These are in the original order, with no de-duplication.
      def self.parse_maven_tree_items_with_depths(file_contents)
        file_contents
          .gsub(ANSI_MATCHER, "")
          .encode(universal_newline: true)
          # capture two groups; one is the ASCII art telling us the tree depth,
          # and two is the actual dependency
          .scan(/^\[INFO\]\s((?:[-+|\\]|\s)*)((?:[\w.-]+:)+[\w.\-${}]+)/)
          # lines that start with "-" aren't part of the tree, example: "[INFO] --- dependency:3.8.1:tree"
          .reject { |(tree_ascii_art, _dep_info)| tree_ascii_art.start_with?("-") }
          .map do |(tree_ascii_art, dep_info)|
            child_marker_index = tree_ascii_art.index(/(\+-)|(\\-)/)
            depth = if child_marker_index.nil?
                      0
                    else
                      # There are three characters present in the line for each level of depth
                      (child_marker_index / 3) + 1
                    end
            [depth, dep_info]
          end
      end

      # split "org.yaml:snakeyaml:jar:2.2:compile" into
      # ["org.yaml:snakeyaml", "2.2", "compile"]
      def self.parse_maven_tree_dependency(item)
        parts = item.split(":")
        case parts.count
        when 4
          version = parts[-1]
          type = parts[-2]
        when 5..6
          version, type = parts[-2..]
        end

        name = parts[0..1].join(":")

        [name, version, type]
      end

      def self.parse_maven_tree(file_contents, options: {})
        keep_subprojects = options.fetch(:keep_subprojects_in_maven_tree, false)

        items = parse_maven_tree_items_with_depths(file_contents)

        raise "found no lines with deps in maven-dependency-tree.txt" if items.empty?

        projects_to_exclude = {}

        (root_name, root_version, _root_type) = parse_maven_tree_dependency(items[0][1])

        # traditional behavior: we only exclude the root project, and only if we parsed multiple lines
        if keep_subprojects && !items.empty?
          items.shift
          projects_to_exclude[root_name] = Set.new
          projects_to_exclude[root_name].add(root_version)
        end

        unique_items = items.map do |(depth, item)|
          # new behavior: we exclude root and subprojects (depth 0 items)
          (name, version, type) = parse_maven_tree_dependency(item)
          if depth == 0 && !keep_subprojects

            # record and then remove the depth 0
            projects_to_exclude[name] ||= Set.new
            projects_to_exclude[name].add(version)
            nil
          else
            [name, version, type]
          end
        end.compact.uniq

        dependencies = unique_items
          # drop the projects and subprojects
          .reject { |(name, version, _type)| projects_to_exclude[name]&.include?(version) }
          .map do |(name, version, type)|
            Bibliothecary::Dependency.new(
              name: name,
              requirement: version,
              type: type,
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          end
        ParserResult.new(
          project_name: root_name,
          dependencies: dependencies
        )
      end

      def self.parse_maven_tree_dot(file_contents, options: {})
        # Project could be either the root project or a sub-module.
        project = file_contents.match(MAVEN_DOT_PROJECT_REGEXP)[1]
        project_name, _project_version, _project_type = parse_maven_tree_dependency(project)
        relationships = file_contents.scan(MAVEN_DOT_RELATIONSHIP_REGEXP)

        direct_names_to_versions = relationships.each.with_object({}) do |(parent, child), obj|
          next unless parent == project

          name, version, _type = parse_maven_tree_dependency(child)
          obj[name] ||= Set.new
          obj[name].add(version)
        end

        deps = relationships.map do |(_parent, child)|
          child_name, child_version, child_type = parse_maven_tree_dependency(child)

          Dependency.new(
            name: child_name,
            requirement: child_version,
            platform: platform_name,
            type: child_type,
            direct: direct_names_to_versions[child_name]&.include?(child_version) || false,
            source: options.fetch(:filename, nil)
          )
        end.uniq

        # TODO: should we change every method to return this, or just allow both to be
        # returned to an analysis? (I'm leaning towards former)
        ParserResult.new(
          dependencies: deps,
          project_name: project_name
        )
      end

      def self.parse_resolved_dep_line(line, options: {})
        # filter out anything that doesn't look like a
        # resolved dep line
        return unless line[/  .*:[^-]+-- /]

        dep_parts = line.strip.split(":")
        return unless dep_parts.length == 5

        # org.springframework.boot:spring-boot-starter-web:jar:2.0.3.RELEASE:compile[36m -- module spring.boot.starter.web[0;1m [auto][m
        Dependency.new(
          name: dep_parts[0, 2].join(":"),
          requirement: dep_parts[3],
          type: dep_parts[4].split("--").first.strip,
          source: options.fetch(:filename, nil),
          platform: platform_name
        )
      end

      def self.parse_standalone_pom_manifest(file_contents, options: {})
        dependencies = parse_pom_manifest(file_contents, {}, options:)
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_pom_manifest(file_contents, parent_properties = {}, options: {})
        parse_pom_manifests([file_contents], parent_properties, options.fetch(:filename, nil))
      end

      # @param files [Array<String>] Ordered array of strings containing the
      # pom.xml bodies. The first element should be the child file.
      # @param merged_properties [Hash]
      def self.parse_pom_manifests(files, merged_properties, source = nil)
        documents = files.map do |file|
          doc = Ox.parse(file)
          doc.respond_to?("project") ? doc.project : doc
        end

        merged_dependency_managements = {}
        documents.each do |document|
          document.locate("dependencyManagement/dependencies/dependency").each do |dep|
            group_id = extract_pom_dep_info(document, dep, "groupId", merged_properties)
            artifact_id = extract_pom_dep_info(document, dep, "artifactId", merged_properties)
            key = "#{group_id}:#{artifact_id}"
            merged_dependency_managements[key] ||=
              {
                groupId: group_id,
                artifactId: artifact_id,
                version: extract_pom_dep_info(document, dep, "version", merged_properties),
                scope: extract_pom_dep_info(document, dep, "scope", merged_properties),
              }
          end
        end

        dep_hashes = {}
        documents.each do |document|
          document.locate("dependencies/dependency").each do |dep|
            group_id = extract_pom_dep_info(document, dep, "groupId", merged_properties)
            artifact_id = extract_pom_dep_info(document, dep, "artifactId", merged_properties)
            key = "#{group_id}:#{artifact_id}"
            unless dep_hashes.key?(key)
              dep_hashes[key] = {
                name: key,
                platform: platform_name,
                requirement: nil,
                type: nil,
                optional: nil,
              }
            end
            dep_hash = dep_hashes[key]

            dep_hash[:requirement] ||= extract_pom_dep_info(document, dep, "version", merged_properties)
            dep_hash[:type] ||= extract_pom_dep_info(document, dep, "scope", merged_properties)

            # optional field is, itself, optional, and will be either "true" or "false"
            optional = extract_pom_dep_info(document, dep, "optional", merged_properties)
            if dep_hash[:optional].nil? && !optional.nil?
              dep_hash[:optional] = optional == "true"
            end
          end
        end

        # Anything that wasn't covered by a dependency version, get from the
        # dependencyManagements
        dep_hashes.each do |key, dep_hash|
          if (dependency_management = merged_dependency_managements[key])
            dep_hash[:requirement] ||= dependency_management[:version]
            dep_hash[:type] ||= dependency_management[:scope]
          end

          dep_hash[:source] = source
        end

        dep_hashes.map { |_key, dep_hash| Dependency.new(**dep_hash) }
      end

      def self.parse_gradle(file_contents, options: {})
        dependencies = file_contents
          .scan(GRADLE_GROOVY_SIMPLE_REGEXP) # match 'implementation "group:artifactId:version"'
          .reject { |(_type, group, artifact_id, _version)| group.nil? || artifact_id.nil? } # remove any matches with missing group/artifactId
          .map do |(type, group, artifact_id, version)|
            Dependency.new(
              name: [group, artifact_id].join(":"),
              requirement: version,
              type: type,
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          end
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_gradle_kts(file_contents, options: {})
        dependencies = file_contents
          .scan(GRADLE_KOTLIN_SIMPLE_REGEXP) # match 'implementation("group:artifactId:version")'
          .reject { |(_type, group, artifact_id, _version)| group.nil? || artifact_id.nil? } # remove any matches with missing group/artifactId
          .map do |(type, group, artifact_id, version)|
            Dependency.new(
              name: [group, artifact_id].join(":"),
              requirement: version,
              type: type,
              source: options.fetch(:filename, nil),
              platform: platform_name
            )
          end
        ParserResult.new(dependencies: dependencies)
      end

      def self.gradle_dependency_name(group, name)
        if group.empty? && name.include?(":")
          group, name = name.split(":", 2)
        end

        # Strip comments, and single/doublequotes
        [group, name].map do |part|
          part
            .gsub(/\s*\/\/.*$/, "") # Comments
            .gsub(/^["']/, "") # Beginning single/doublequotes
            .gsub(/["']$/, "") # Ending single/doublequotes
        end.join(":")
      end

      def self.extract_pom_info(xml, location, parent_properties = {})
        extract_pom_dep_info(xml, xml, location, parent_properties)
      end

      # TODO: it might be worth renaming parent_properties to parent_elements
      # so that more can be inherited from the parent pom than just <properties>
      # here (see https://maven.apache.org/pom.html#inheritance)
      def self.extract_pom_dep_info(xml, dependency, name, parent_properties = {})
        field = dependency.locate(name).first
        return nil if field.nil?

        value = field.nodes.first
        value = value.value if value.is_a?(Ox::CData)
        # whitespace in dependency tags should be ignored
        value = value&.strip
        match = value&.match(MAVEN_PROPERTY_REGEXP)
        return extract_property(xml, match[1], value, parent_properties) if match

        value
      end

      def self.replace_value_with_prop(original_value, property_value, property_name)
        original_value.gsub("${#{property_name}}", property_value)
      end

      def self.extract_property(xml, property_name, value, parent_properties = {}, depth = 0)
        prop_value = property_value(xml, property_name, parent_properties)
        return value unless prop_value

        # don't resolve more than 5 levels deep to avoid potential circular references

        resolved_value = replace_value_with_prop(value, prop_value, property_name)
        # check to see if we just resolved to another property name
        match = resolved_value.match(MAVEN_PROPERTY_REGEXP)
        return resolved_value unless match && depth < MAX_DEPTH

        depth += 1
        extract_property(xml, match[1], resolved_value, parent_properties, depth)
      end

      def self.property_value(xml, property_name, parent_properties)
        # the xml root is <project> so lookup the non property name in the xml
        # this converts ${project/group.id} -> ${group/id}
        non_prop_name = property_name.gsub(".", "/").gsub("project/", "")

        prop_field = xml.properties.locate(property_name).first if xml.respond_to?("properties")
        parent_prop = parent_properties[property_name] || # e.g. "${foo}"
                      parent_properties[property_name.sub(/^project\./, "")] ||       # e.g. "${project.foo}"
                      parent_properties[property_name.sub(/^project\.parent\./, "")]  # e.g. "${project.parent.foo}"

        if prop_field
          prop_field.nodes.first
        elsif parent_prop
          parent_prop
        elsif xml.locate(non_prop_name).first
          # see if the value to look up is a field under the project
          # examples are ${project.groupId} or ${project.version}
          xml.locate(non_prop_name).first.nodes.first
        elsif xml.locate("parent/#{non_prop_name}").first
          # see if the value to look up is a field under the project parent
          # examples are ${project.groupId} or ${project.version}
          xml.locate("parent/#{non_prop_name}").first.nodes.first
        end
      end

      def self.parse_sbt_update_full(file_contents, options: {})
        all_deps = []
        lines = file_contents.split("\n")
        while lines.any?
          line = lines.shift

          type_match = SBT_TYPE_REGEXP.match(line)
          next unless type_match

          type = type_match.captures[0]

          deps = parse_sbt_deps(type, lines)
          all_deps.concat(deps)
        end

        # strip out evicted dependencies
        all_deps.reject! do |dep|
          dep[:fields]["evicted"] == "true"
        end

        # in the future, we could use "callers" in the fields to
        # decide which deps are direct root deps and which are
        # pulled in by another dep.  The direct deps have the sbt
        # project name as a caller.

        # clean out any duplicates (I'm pretty sure sbt will have done this for
        # us so this is paranoia, basically)
        squished = all_deps.compact.uniq { |item| [item[:name], item[:requirement], item[:type]] }

        # get rid of the fields
        squished.each do |dep|
          dep.delete(:fields)
        end

        dependencies = squished.map do |dep_kvs|
          Dependency.new(
            **dep_kvs,
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_sbt_deps(type, lines)
        deps = []
        while lines.any? && !SBT_TYPE_REGEXP.match(lines[0])
          line = lines.shift

          next if SBT_IGNORE_REGEXP.match(line)

          dep_match = SBT_DEP_REGEXP.match(line)
          if dep_match
            versions = parse_sbt_versions(type, dep_match.captures[0], lines)
            deps.concat(versions)
          else
            lines.unshift(line)
            break
          end
        end

        deps
      end

      def self.parse_sbt_versions(type, name, lines)
        versions = []
        while lines.any? && !SBT_TYPE_REGEXP.match(lines[0])
          line = lines.shift

          version_match = SBT_VERSION_REGEXP.match(line)
          if version_match
            versions.push(parse_sbt_version(type, name, version_match.captures[0], lines))
          else
            lines.unshift(line)
            break
          end
        end

        versions
      end

      def self.parse_sbt_version(type, name, version, lines)
        fields = {}
        while lines.any? && !SBT_TYPE_REGEXP.match(lines[0])
          line = lines.shift

          field_match = SBT_FIELD_REGEXP.match(line)
          if field_match
            fields[field_match.captures[0]] = field_match.captures[1]
          else
            lines.unshift(line)
            break
          end
        end

        {
          name: name,
          requirement: version,
          type: type,
          # we post-process using some of these fields and then delete them again
          fields: fields,
        }
      end
    end
  end
end
