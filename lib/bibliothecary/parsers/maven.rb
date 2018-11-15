require 'ox'

module Bibliothecary
  module Parsers
    class Maven
      include Bibliothecary::Analyser

      # e.g. "annotationProcessor - Annotation processors and their dependencies for source set 'main'."
      GRADLE_TYPE_REGEX = /^(\w+)/

      # "|    \\--- com.google.guava:guava:23.5-jre (*)"
      GRADLE_DEP_REGEX = /(\+---|\\---){1}/

      def self.mapping
        {
          /^ivy\.xml$|.*\/ivy\.xml$/i => {
            kind: 'manifest',
            parser: :parse_ivy_manifest
          },
          /^pom\.xml$|.*\/pom\.xml$/i => {
            kind: 'manifest',
            parser: :parse_pom_manifest
          },
          /^build.gradle$|.*\/build.gradle$/i => {
            kind: 'manifest',
            parser: :parse_gradle
          },
          /^.+.xml$/i => {
            content_matcher: :ivy_report?,
            kind: 'lockfile',
            parser: :parse_ivy_report
          },
          /^gradle-dependencies-q\.txt|.*\/gradle-dependencies-q\.txt$/i => {
            kind: 'lockfile',
            parser: :parse_gradle_resolved
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
      rescue Exception => e
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
          # Lines can end with (n) or (*) to indicate that something was not resolved (n) or resolved previously (*).
          dep = line.split(split)[1].sub(/\(n\)$/, "").sub(/\(\*\)$/,"").strip.split(":")
          version = dep[-1]
          version = version.split("->")[-1].strip if line.include?("->")
          {
            name: dep[0, dep.length - 1].join(":"),
            requirement: version,
            type: type
          }
        end.compact
      end

      def self.parse_pom_manifest(file_contents)
        manifest = Ox.parse file_contents
        if manifest.respond_to?('project')
          xml = manifest.project
        else
          xml = manifest
        end
        return [] unless xml.respond_to?('dependencies')
        xml.dependencies.locate('dependency').map do |dependency|
          {
            name: "#{extract_pom_dep_info(xml, dependency, 'groupId')}:#{extract_pom_dep_info(xml, dependency, 'artifactId')}",
            requirement: extract_pom_dep_info(xml, dependency, 'version'),
            type: extract_pom_dep_info(xml, dependency, 'scope') || 'runtime'
          }
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

      def self.extract_pom_dep_info(xml, dependency, name)
        field = dependency.locate(name).first
        return nil if field.nil?
        value = field.nodes.first
        match = value.match(/^\$\{(.+)\}/)
        if match
          prop_field = xml.properties.locate(match[1]).first
          if prop_field
            return prop_field.nodes.first
          else
            return value
          end
        else
          return value
        end
      end
    end
  end
end
