require 'ox'
require 'strings-ansi'

# Known shortcomings and unimplemented Maven features:
#   pom.xml
#     <exclusions> cannot be taken into account (because it requires knowledge of transitive deps)
#     <properties> are the only thing inherited from parent poms currenly
module Bibliothecary
  module Parsers
    class Maven
      include Bibliothecary::Analyser

      # e.g. "annotationProcessor - Annotation processors and their dependencies for source set 'main'."
      GRADLE_TYPE_REGEX = /^(\w+)/

      # e.g. "|    \\--- com.google.guava:guava:23.5-jre (*)"
      GRADLE_DEP_REGEX = /(\+---|\\---){1}/

      # Dependencies that are on-disk projects, eg:
      # e.g. "\--- project :api:my-internal-project"
      # e.g. "+--- my-group:my-alias:1.2.3 -> project :client (*)"
      GRADLE_PROJECT_REGEX = /project :(\S+)?/

      # line ending legend: (c) means a dependency constraint, (n) means not resolved, or (*) means resolved previously, e.g. org.springframework.boot:spring-boot-starter-web:2.1.0.M3 (*)
      # e.g. the "(n)" in "+--- my-group:my-name:1.2.3 (n)"
      GRADLE_LINE_ENDING_REGEX = /(\((c|n|\*)\))$/

      # Builtin methods: https://docs.gradle.org/current/userguide/java_plugin.html#tab:configurations
      # Deprecated methods: https://docs.gradle.org/current/userguide/upgrading_version_6.html#sec:configuration_removal
      GRADLE_DEPENDENCY_METHODS = %w(api compile compileClasspath compileOnly compileOnlyApi implementation runtime runtimeClasspath runtimeOnly testCompile testCompileOnly testImplementation testRuntime testRuntimeOnly)

      # Intentionally overly-simplified regexes to scrape deps from build.gradle (Groovy) and build.gradle.kts (Kotlin) files.
      # To be truly useful bibliothecary would need full Groovy / Kotlin parsers that speaks Gradle,
      # because the Groovy and Kotlin DSLs have many dynamic ways of declaring dependencies.
      GRADLE_VERSION_REGEX = /[\w.-]+/ # e.g. '1.2.3'
      GRADLE_VAR_INTERPOLATION_REGEX = /\$\w+/ # e.g. '$myVersion'
      GRADLE_CODE_INTERPOLATION_REGEX = /\$\{.*\}/ # e.g. '${my-project-settings["version"]}'
      GRADLE_GAV_REGEX = /([\w.-]+)\:([\w.-]+)(?:\:(#{GRADLE_VERSION_REGEX}|#{GRADLE_VAR_INTERPOLATION_REGEX}|#{GRADLE_CODE_INTERPOLATION_REGEX}))?/ # e.g. "group:artifactId:1.2.3"
      GRADLE_GROOVY_SIMPLE_REGEX = /(#{GRADLE_DEPENDENCY_METHODS.join('|')})\s*\(?\s*['"]#{GRADLE_GAV_REGEX}['"]/m
      GRADLE_KOTLIN_SIMPLE_REGEX = /(#{GRADLE_DEPENDENCY_METHODS.join('|')})\s*\(\s*"#{GRADLE_GAV_REGEX}"/m

      MAVEN_PROPERTY_REGEX = /\$\{(.+?)\}/
      MAX_DEPTH = 5

      # e.g. "[info]  test:"
      SBT_TYPE_REGEX = /^\[info\]\s+([-\w]+):$/

      # e.g. "[info]  org.typelevel:spire-util_2.12"
      SBT_DEP_REGEX = /^\[info\]\s+(.+)$/

      # e.g. "[info] 		- 1.7.5"
      SBT_VERSION_REGEX = /^\[info\]\s+-\s+(.+)$/

      # e.g. "[info] 			homepage: http://www.slf4j.org"
      SBT_FIELD_REGEX = /^\[info\]\s+([^:]+):\s+(.+)$/

      # e.g. "[info]  "
      SBT_IGNORE_REGEX = /^\[info\]\s*$/

      def self.mapping
        {
          match_filename("ivy.xml", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_ivy_manifest
          },
          match_filename("pom.xml", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_standalone_pom_manifest
          },
          match_filename("build.gradle", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_gradle
          },
          match_filename("build.gradle.kts", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_gradle_kts
          },
          match_extension(".xml", case_insensitive: true) => {
            content_matcher: :ivy_report?,
            kind: 'lockfile',
            parser: :parse_ivy_report
          },
          match_filename("gradle-dependencies-q.txt", case_insensitive: true) => {
            kind: 'lockfile',
            parser: :parse_gradle_resolved
          },
          match_filename("maven-resolved-dependencies.txt", case_insensitive: true) => {
            kind: 'lockfile',
            parser: :parse_maven_resolved
          },
          match_filename("sbt-update-full.txt", case_insensitive: true) => {
            kind: 'lockfile',
            parser: :parse_sbt_update_full
          },
          match_filename("maven-dependency-tree.txt", case_insensitive: true) => {
            kind: 'lockfile',
            parser: :parse_maven_tree
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_ivy_manifest(file_contents, options: {})
        manifest = Ox.parse file_contents
        manifest.dependencies.locate('dependency').map do |dependency|
          attrs = dependency.attributes
          {
            name: "#{attrs[:org]}:#{attrs[:name]}",
            requirement: attrs[:rev],
            type: 'runtime'
          }
        end
      end

      def self.ivy_report?(file_contents)
        doc = Ox.parse file_contents
        root = doc&.locate("ivy-report")&.first
        return !root.nil?
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
        modules.map do |mod|
          attrs = mod.attributes
          org = attrs[:organisation]
          name = attrs[:name]
          version = mod.locate('revision').first&.attributes[:name]

          next nil if org.nil? or name.nil? or version.nil?

          {
            name: "#{org}:#{name}",
            requirement: version,
            type: type
          }
        end.compact
      end

      def self.parse_gradle_resolved(file_contents, options: {})
        current_type = nil

        file_contents.split("\n").map do |line|
          current_type_match = GRADLE_TYPE_REGEX.match(line)
          current_type = current_type_match.captures[0] if current_type_match

          gradle_dep_match = GRADLE_DEP_REGEX.match(line)
          next unless gradle_dep_match

          split = gradle_dep_match.captures[0]

          # gradle can import on-disk projects and deps will be listed under them, e.g. `+--- project :test:integration`,
          # so we treat these projects as "internal" deps with requirement of "1.0.0"
          if (project_match = line.match(GRADLE_PROJECT_REGEX))
            # an empty project name is self-referential (i.e. a cycle), and we don't need to track the manifest's project itself, e.g. "+--- project :"
            next if project_match[1].nil?

            # project names can have colons (e.g. for gradle projects in subfolders), which breaks maven artifact naming assumptions, so just replace them with hyphens.
            project_name = project_match[1].gsub(/:/, "-")
            line = line.sub(GRADLE_PROJECT_REGEX, "internal:#{project_name}:1.0.0")
          end

          dep = line
            .split(split)[1]
            .sub(GRADLE_LINE_ENDING_REGEX, "")
            .sub(/ FAILED$/, "") # dependency could not be resolved (but still may have a version)
            .sub(" -> ", ":") # handle version arrow syntax
            .strip
            .split(":")

          # A testImplementation line can look like this so just skip those
          # \--- org.springframework.security:spring-security-test (n)
          next unless dep.length >= 3

          if dep.count == 6
            # get name from renamed package resolution "org:name:version -> renamed_org:name:version"
            {
              original_name: dep[0,2].join(":"),
              original_requirement: dep[2],
              name: dep[-3..-2].join(":"),
              requirement: dep[-1],
              type: current_type
            }
          elsif dep.count == 5
            # get name from renamed package resolution "org:name -> renamed_org:name:version"
            {
              original_name: dep[0,2].join(":"),
              original_requirement: "*",
              name: dep[-3..-2].join(":"),
              requirement: dep[-1],
              type: current_type
            }
          else
            # get name from version conflict resolution ("org:name:version -> version") and no-resolution ("org:name:version")
            {
              name: dep[0..1].join(":"),
              requirement: dep[-1],
              type: current_type
            }
          end
        end
          .compact
          .uniq { |item| item.values_at(:name, :requirement, :type, :original_name, :original_requirement) }
      end

      def self.parse_maven_resolved(file_contents, options: {})
        Strings::ANSI.sanitize(file_contents)
          .split("\n")
          .map(&method(:parse_resolved_dep_line))
          .compact
          .uniq
      end

      def self.parse_maven_tree(file_contents, options: {})
        captures = Strings::ANSI.sanitize(file_contents)
          .gsub(/\r\n?/, "\n")
          .scan(/^\[INFO\](?:(?:\+-)|\||(?:\\-)|\s)+((?:[\w\.-]+:)+[\w\.\-${}]+)/)
          .flatten
          .uniq

        deps = captures.map do |item|
          parts = item.split(":")
          case parts.count
          when 4
            version = parts[-1]
            type = parts[-2]
          when 5..6
            version, type = parts[-2..]
          end
          {
            name: parts[0..1].join(":"),
            requirement: version,
            type: type
          }
        end

        # First dep line will be the package itself (unless we're only analyzing a single line)
        package = deps[0]
        deps.size < 2 ? deps : deps[1..-1].reject { |d| d[:name] == package[:name] && d[:requirement] == package[:requirement] }
      end

      def self.parse_resolved_dep_line(line)
        dep_parts = line.strip.split(":")
        return unless dep_parts.length == 5
        # org.springframework.boot:spring-boot-starter-web:jar:2.0.3.RELEASE:compile[36m -- module spring.boot.starter.web[0;1m [auto][m
        {
          name: dep_parts[0, 2].join(":"),
          requirement: dep_parts[3],
          type: dep_parts[4].split("--").first.strip
        }
      end

      def self.parse_standalone_pom_manifest(file_contents, options: {})
        parse_pom_manifest(file_contents, {}, options: options)
      end

      # parent_properties is used by Libraries:
      # https://github.com/librariesio/libraries.io/blob/e970925aade2596a03268b6e1be785eba8502c62/app/models/package_manager/maven.rb#L129
      def self.parse_pom_manifest(file_contents, parent_properties = {}, options: {})
        manifest = Ox.parse file_contents
        xml = manifest.respond_to?('project') ? manifest.project : manifest
        [].tap do |deps|
          # <dependencyManagement> is a namespace to specify artifact configuration (e.g. version), but it doesn't
          # actually add dependencies to your project. Grab these and keep them for reference while parsing <dependencies>
          # Ref: https://maven.apache.org/pom.html#Dependency_Management
          # Ref: https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#transitive-dependencies
          dependencyManagement = xml.locate("dependencyManagement/dependencies/dependency").map do |dep|
            {
              groupId: extract_pom_dep_info(xml, dep, "groupId", parent_properties),
              artifactId: extract_pom_dep_info(xml, dep, "artifactId", parent_properties),
              version: extract_pom_dep_info(xml, dep, "version", parent_properties),
              scope: extract_pom_dep_info(xml, dep, "scope", parent_properties),
            }
          end
          # <dependencies> is the namespace that will add dependencies to your project.
          xml.locate("dependencies/dependency").each do |dep|
            groupId = extract_pom_dep_info(xml, dep, 'groupId', parent_properties)
            artifactId = extract_pom_dep_info(xml, dep, 'artifactId', parent_properties)
            version = extract_pom_dep_info(xml, dep, 'version', parent_properties)
            scope = extract_pom_dep_info(xml, dep, 'scope', parent_properties)

            # Use any dep configurations from <dependencyManagement> as fallbacks
            if (depConfig = dependencyManagement.find { |d| d[:groupId] == groupId && d[:artifactId] == artifactId })
              version ||= depConfig[:version]
              scope ||= depConfig[:scope]
            end

            dep_hash = {
              name: "#{groupId}:#{artifactId}",
              requirement: version,
              type: scope || 'runtime',
            }
            # optional field is, itself, optional, and will be either "true" or "false"
            optional = extract_pom_dep_info(xml, dep, 'optional', parent_properties)
            dep_hash[:optional] = optional == "true" unless optional.nil?
            deps.push(dep_hash)
          end
        end
      end

      def self.parse_gradle(file_contents, options: {})
        file_contents
        .scan(GRADLE_GROOVY_SIMPLE_REGEX)                                                # match 'implementation "group:artifactId:version"'
        .reject { |(_type, group, artifactId, _version)| group.nil? || artifactId.nil? } # remove any matches with missing group/artifactId
        .map { |(type, group, artifactId, version)|
          {
            name: [group, artifactId].join(":"),
            requirement: version || "*",
            type: type
          }
        }
      end

      def self.parse_gradle_kts(file_contents, options: {})
        file_contents
          .scan(GRADLE_KOTLIN_SIMPLE_REGEX)                                                # match 'implementation("group:artifactId:version")'
          .reject { |(_type, group, artifactId, _version)| group.nil? || artifactId.nil? } # remove any matches with missing group/artifactId
          .map { |(type, group, artifactId, version)|
            {
              name: [group, artifactId].join(":"),
              requirement: version || "*",
              type: type
            }
          }
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
        match = value&.match(MAVEN_PROPERTY_REGEX)
        if match
          return extract_property(xml, match[1], value, parent_properties)
        else
          return value
        end
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
        match = resolved_value.match(MAVEN_PROPERTY_REGEX)
        if match && depth < MAX_DEPTH
          depth += 1
          return extract_property(xml, match[1], resolved_value, parent_properties, depth)
        else
          return resolved_value
        end
      end

      def self.property_value(xml, property_name, parent_properties)
        # the xml root is <project> so lookup the non property name in the xml
        # this converts ${project/group.id} -> ${group/id}
        non_prop_name = property_name.gsub(".", "/").gsub("project/", "")
        return "${#{property_name}}" if !xml.respond_to?("properties") && parent_properties.empty? && xml.locate(non_prop_name).empty?

        prop_field = xml.properties.locate(property_name).first if xml.respond_to?("properties")
        parent_prop = parent_properties[property_name] ||                 # e.g. "${foo}"
          parent_properties[property_name.sub(/^project\./, '')] ||       # e.g. "${project.foo}"
          parent_properties[property_name.sub(/^project\.parent\./, '')]  # e.g. "${project.parent.foo}"

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
        type = nil
        lines = file_contents.split("\n")
        while lines.any?
          line = lines.shift

          type_match = SBT_TYPE_REGEX.match(line)
          next unless type_match
          type = type_match.captures[0]

          deps = parse_sbt_deps(type, lines)
          all_deps.concat(deps)
        end

        # strip out evicted dependencies
        all_deps.select! do |dep|
          dep[:fields]["evicted"] != "true"
        end

        # in the future, we could use "callers" in the fields to
        # decide which deps are direct root deps and which are
        # pulled in by another dep.  The direct deps have the sbt
        # project name as a caller.

        # clean out any duplicates (I'm pretty sure sbt will have done this for
        # us so this is paranoia, basically)
        squished = all_deps.compact.uniq {|item| [item[:name], item[:requirement], item[:type]]}

        # get rid of the fields
        squished.each do |dep|
          dep.delete(:fields)
        end

        return squished
      end

      def self.parse_sbt_deps(type, lines)
        deps = []
        while lines.any? and not SBT_TYPE_REGEX.match(lines[0])
          line = lines.shift

          next if SBT_IGNORE_REGEX.match(line)

          dep_match = SBT_DEP_REGEX.match(line)
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
        while lines.any? and not SBT_TYPE_REGEX.match(lines[0])
          line = lines.shift

          version_match = SBT_VERSION_REGEX.match(line)
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
        while lines.any? and not SBT_TYPE_REGEX.match(lines[0])
          line = lines.shift

          field_match = SBT_FIELD_REGEX.match(line)
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
          fields: fields
        }
      end
    end
  end
end
