# frozen_string_literal: true

# packageurl-ruby uses pattern-matching (https://docs.ruby-lang.org/en/2.7.0/NEWS.html#label-Pattern+matching)
# which warns a whole bunch in Ruby 2.7 as being an experimental feature, but has
# been accepted in Ruby 3.0 (https://rubyreferences.github.io/rubychanges/3.0.html#pattern-matching).
Warning[:experimental] = false
require "package_url"
Warning[:experimental] = true

module Bibliothecary
  module MultiParsers
    class Spdx
      include Bibliothecary::Analyser
      extend Bibliothecary::Analyser::TryCache

      # e.g. 'SomeText:' (allowing for leading whitespace)
      WELLFORMED_LINE_REGEXP = /^\s*[a-zA-Z]+:/

      # e.g. 'PackageName: (allowing for excessive whitespace)
      PACKAGE_NAME_REGEXP = /^\s*PackageName:\s*(.*)/

      # e.g. 'PackageVersion:' (allowing for excessive whitespace)
      PACKAGE_VERSION_REGEXP = /^\s*PackageVersion:\s*(.*)/

      # e.g. "ExternalRef: PACKAGE-MANAGER purl (allowing for excessive whitespace)
      PURL_REGEXP = /^\s*ExternalRef:\s*PACKAGE[-|_]MANAGER\s*purl\s*(.*)/

      NoEntries = Class.new(StandardError)
      MalformedFile = Class.new(StandardError)

      def self.mapping
        {
          match_extension(".spdx") => {
            kind: "lockfile",
            parser: :parse_spdx_tag_value,
            ungroupable: true,
          },
          match_extension(".spdx.json") => {
            kind: "lockfile",
            parser: :parse_spdx_json,
            ungroupable: true,
          },
        }
      end

      def self.platform_name
        raise "Spdx is a multi-parser and does not have a platform name."
      end

      def self.parse_spdx_tag_value(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_spdx_tag_value_file_contents(
            file_contents,
            options.fetch(:filename, nil)
          )
        end

        raise NoEntries if entries.empty?

        Bibliothecary::ParserResult.new(dependencies: entries.to_a)
      end

      def self.parse_spdx_tag_value_file_contents(file_contents, source = nil)
        entries = Set.new
        spdx_name = spdx_version = platform = purl_name = purl_version = purl_type = nil

        file_contents.each_line do |line|
          stripped_line = line.strip
          next if skip_tag_value_line?(stripped_line)

          raise MalformedFile unless stripped_line.match?(WELLFORMED_LINE_REGEXP)

          if (match = stripped_line.match(PACKAGE_NAME_REGEXP))
            # Per the spec:
            # > A new package Information section is denoted by the package name (7.1) field.
            add_entry(entries: entries, platform: platform, purl_name: purl_name,
                      spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version,
                      source: source, purl_type: purl_type)

            # reset for this new package
            spdx_name = spdx_version = platform = purl_name = purl_version = purl_type = nil

            # capture the new package's name
            spdx_name = match[1]
          elsif (match = stripped_line.match(PACKAGE_VERSION_REGEXP))
            spdx_version = match[1]
          elsif (match = stripped_line.match(PURL_REGEXP))
            purl = PackageURL.parse(match[1])
            purl_type ||= purl&.type
            # Use the mapped purl->bibliothecary platform, or else fall back to original platform itself.
            platform = PurlUtil::PURL_TYPE_MAPPING.fetch(purl_type, purl_type)
            purl_name ||= PurlUtil.full_name(purl)
            purl_version ||= purl&.version
          end
        end

        add_entry(entries: entries, platform: platform, purl_name: purl_name,
                  spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version,
                  source: source, purl_type: purl_type)

        entries
      end

      def self.skip_tag_value_line?(stripped_line)
        # Ignore blank lines and comments
        stripped_line.empty? || stripped_line.start_with?("#")
      end

      def self.parse_spdx_json(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_spdx_json_file_contents(
            file_contents,
            options.fetch(:filename, nil)
          )
        end

        raise NoEntries if entries.empty?

        Bibliothecary::ParserResult.new(dependencies: entries.to_a)
      end

      def self.parse_spdx_json_file_contents(file_contents, source = nil)
        manifest = JSON.parse(file_contents)

        if manifest.key?("spdxVersion")
          parse_spdx_1_and_2_json_file_contents(manifest, source)
        elsif manifest.key?("@context")
          parse_spdx_3_json_file_contents(manifest, source)
        else
          Set.new
        end
      end

      def self.parse_spdx_1_and_2_json_file_contents(manifest, source)
        entries = Set.new
        manifest["packages"]&.each do |package|
          spdx_name = package["name"]
          spdx_version = package["versionInfo"]

          first_purl_string = package["externalRefs"]&.find { |ref| ref["referenceType"] == "purl" }&.dig("referenceLocator")
          purl = first_purl_string && PackageURL.parse(first_purl_string)
          purl_type = purl&.type
          # Use the mapped purl->bibliothecary platform, or else fall back to original platform itself.
          platform = PurlUtil::PURL_TYPE_MAPPING.fetch(purl_type, purl_type)
          purl_name = PurlUtil.full_name(purl)
          purl_version = purl&.version

          add_entry(entries: entries, platform: platform, purl_name: purl_name,
                    spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version,
                    source: source, purl_type: purl_type)
        end
        entries
      end

      def self.parse_spdx_3_json_file_contents(manifest, source)
        entries = Set.new
        manifest.fetch("@graph", [])
          .select do |element|
            types = Array(element["type"] || element["@type"])
            # "software_Package" is the common one, but these may differ and include namespaces
            types.any? { |t| t.to_s.match?(/Package$/i) }
          end
          .each do |element|
            spdx_name = element["name"]
            spdx_version = element["software_packageVersion"] || element["packageVersion"] || element["versionInfo"]

            purl_string = element["externalIdentifier"]&.find do |ext_id|
              ext_id_type = ext_id["externalIdentifierType"] || ext_id["identifierType"]
              ext_id_type&.match?(/purl/i)
            end&.dig("identifier")

            purl_string ||= element.fetch("externalRef", [])
              .map { |ref| ref.fetch("locator", nil) }
              .compact
              .map(&:first)
              .find { |locator| locator.start_with?("pkg:") }

            purl_string ||= element.fetch("software_packageUrl", nil)

            next unless purl_string

            purl = PackageURL.parse(purl_string)
            purl_type = purl&.type
            # Use the mapped purl->bibliothecary platform, or else fall back to original platform itself.
            platform = PurlUtil::PURL_TYPE_MAPPING.fetch(purl_type, purl_type)
            purl_name = PurlUtil.full_name(purl)
            purl_version = purl&.version

            add_entry(entries: entries, platform: platform, purl_name: purl_name,
                      spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version,
                      source: source, purl_type: purl_type)
          end

        entries
      end

      def self.add_entry(entries:, platform:, purl_name:, spdx_name:, purl_version:, spdx_version:, source: nil, purl_type: nil)
        package_name = purl_name || spdx_name
        package_version = purl_version || spdx_version

        return unless package_name && package_version
        return unless platform

        entries << Dependency.new(
          platform: platform ? platform.to_s : purl_type,
          name: package_name,
          requirement: package_version,
          type: "lockfile",
          source: source
        )
      end
    end
  end
end
