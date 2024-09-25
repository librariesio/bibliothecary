# packageurl-ruby uses pattern-matching (https://docs.ruby-lang.org/en/2.7.0/NEWS.html#label-Pattern+matching)
# which warns a whole bunch in Ruby 2.7 as being an experimental feature, but has
# been accepted in Ruby 3.0 (https://rubyreferences.github.io/rubychanges/3.0.html#pattern-matching).
Warning[:experimental] = false
require "package_url"
Warning[:experimental] = true

module Bibliothecary
  module MultiParsers
    module Spdx
      include Bibliothecary::Analyser
      include Bibliothecary::Analyser::TryCache

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

      def parse_spdx_tag_value(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_spdx_tag_value_file_contents(file_contents)
        end

        raise NoEntries if entries.empty?

        entries[platform_name.to_sym]
      end

      def parse_spdx_tag_value_file_contents(file_contents)
        entries = {}
        spdx_name = spdx_version = platform = purl_name = purl_version = nil

        file_contents.each_line do |line|
          stripped_line = line.strip
          next if skip_tag_value_line?(stripped_line)

          raise MalformedFile unless stripped_line.match?(WELLFORMED_LINE_REGEXP)

          if (match = stripped_line.match(PACKAGE_NAME_REGEXP))
            # Per the spec:
            # > A new package Information section is denoted by the package name (7.1) field.
            add_entry(entries: entries, platform: platform, purl_name: purl_name,
                      spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version)

            # reset for this new package
            spdx_name = spdx_version = platform = purl_name = purl_version = nil

            # capture the new package's name
            spdx_package_name = match[1]
          elsif (match = stripped_line.match(PACKAGE_VERSION_REGEXP))
            spdx_version = match[1]
          elsif (match = stripped_line.match(PURL_REGEXP))
            purl = PackageURL.parse(match[1])
            platform ||= purl.type
            purl_name ||= PurlUtil.full_name(purl)
            purl_version ||= purl.version
          end
        end

        add_entry(entries: entries, platform: platform, purl_name: purl_name,
                  spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version)

        entries
      end

      def skip_tag_value_line?(stripped_line)
        # Ignore blank lines and comments
        stripped_line.empty? || stripped_line.start_with?("#")
      end

      def parse_spdx_json(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_spdx_json_file_contents(file_contents)
        end

        raise NoEntries if entries.empty?

        entries[platform_name.to_sym]
      end

      def parse_spdx_json_file_contents(file_contents)
        entries = {}
        manifest = JSON.parse(file_contents)

        manifest["packages"]&.each do |package|
          spdx_name = package["name"]
          spdx_version = package["versionInfo"]

          first_purl_string = package.dig("externalRefs")&.find { |ref| ref["referenceType"] == "purl" }&.dig("referenceLocator")
          purl = first_purl_string && PackageURL.parse(first_purl_string)
          platform = purl&.type
          purl_name = PurlUtil.full_name(purl)
          purl_version = purl&.version

          add_entry(entries: entries, platform: platform, purl_name: purl_name,
                    spdx_name: spdx_name, purl_version: purl_version, spdx_version: spdx_version)
        end

        entries
      end

      def add_entry(entries:, platform:, purl_name:, spdx_name:, purl_version:, spdx_version:)
        package_name = purl_name || spdx_name
        package_version = purl_version || spdx_version

        if platform && package_name && package_version
          entries[platform.to_sym] ||= []
          entries[platform.to_sym] << Dependency.new(
            name: package_name,
            requirement: package_version,
            type: "lockfile"
          )
        end
      end

    end
  end
end
