require 'ox'
require 'strings-ansi'

module Bibliothecary
  module Parsers
    class Maven
      include Bibliothecary::Analyser

      # e.g. "annotationProcessor - Annotation processors and their dependencies for source set 'main'."
      GRADLE_TYPE_REGEX = /^(\w+)/

      # "|    \\--- com.google.guava:guava:23.5-jre (*)"
      GRADLE_DEP_REGEX = /(\+---|\\---){1}/

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
            parser: :parse_pom_manifest
          },
          match_filename("build.gradle", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_gradle
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

      def self.parse_ivy_manifest(file_contents)
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

      def self.parse_ivy_report(file_contents)
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

      def self.parse_gradle_resolved(file_contents)
        type = nil
        file_contents.split("\n").map do |line|
          type_match = GRADLE_TYPE_REGEX.match(line)
          type = type_match.captures[0] if type_match

          gradle_dep_match = GRADLE_DEP_REGEX.match(line)
          next unless gradle_dep_match

          split = gradle_dep_match.captures[0]

          # org.springframework.boot:spring-boot-starter-web:2.1.0.M3 (*)
          # Lines can end with (c), (n), or (*)
          # to indicate that something was a dependency constraint (c), not resolved (n), or resolved previously (*).
          dep = line.split(split)[1].sub(/(\((c|n|\*)\))$/, "").sub(" -> ", ":").strip.split(":")

          # A testImplementation line can look like this so just skip those
          # \--- org.springframework.security:spring-security-test (n)
          next unless dep.length >= 3

          version = dep[-1]
          {
            name: dep[0..1].join(":"),
            requirement: version,
            type: type
          }
        end.compact.uniq {|item| [item[:name], item[:requirement], item[:type]]}
      end

      def self.parse_maven_resolved(file_contents)
        Strings::ANSI.sanitize(file_contents)
          .split("\n")
          .map(&method(:parse_resolved_dep_line))
          .compact
          .uniq
      end
      def self.parse_maven_tree(file_contents)
        file_contents = file_contents.gsub(/\r\n?/, "\n")
        captures = file_contents.scan(/^\[INFO\](?:(?:\+-)|\||(?:\\-)|\s)+((?:[\w\.-]+:)+[\w\.\-${}]+)/).flatten.uniq
        captures.map do |item|
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

      def self.parse_pom_manifest(file_contents, parent_properties = {})
        manifest = Ox.parse file_contents
        xml = manifest.respond_to?('project') ? manifest.project : manifest
        [].tap do |deps|
          ['dependencies/dependency', 'dependencyManagement/dependencies/dependency'].each do |deps_xpath|
            xml.locate(deps_xpath).each do |dep|
              deps.push({
                name: "#{extract_pom_dep_info(xml, dep, 'groupId', parent_properties)}:#{extract_pom_dep_info(xml, dep, 'artifactId', parent_properties)}",
                requirement: extract_pom_dep_info(xml, dep, 'version', parent_properties),
                type: extract_pom_dep_info(xml, dep, 'scope', parent_properties) || 'runtime'
              })
            end
          end
        end
      end

      def self.parse_gradle(manifest)
        response = Typhoeus.post("#{Bibliothecary.configuration.gradle_parser_host}/parse", body: manifest)
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.gradle_parser_host}/parse", response.response_code) unless response.success?
        json = JSON.parse(response.body)
        return [] unless json['dependencies']
        json['dependencies'].map do |dependency|
          name = [dependency["group"], dependency["name"]].join(':')
          next unless name =~ (/[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+(\.[A-Za-z0-9_-])?\:[A-Za-z0-9_-]/)
          {
            name: name,
            requirement: dependency["version"],
            type: dependency["type"]
          }
        end.compact
      end

      def self.extract_pom_info(xml, location, parent_properties = {})
        extract_pom_dep_info(xml, xml, location, parent_properties)
      end

      def self.extract_pom_dep_info(xml, dependency, name, parent_properties = {})
        field = dependency.locate(name).first
        return nil if field.nil?

        value = field.nodes.first
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

        prop_field = xml.properties.locate(property_name).first
        parent_prop = parent_properties[property_name]
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

      def self.parse_sbt_update_full(file_contents)
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
