# packageurl-ruby uses pattern-matching (https://docs.ruby-lang.org/en/2.7.0/NEWS.html#label-Pattern+matching)
# which warns a whole bunch in Ruby 2.7 as being an experimental feature, but has
# been accepted in Ruby 3.0 (https://rubyreferences.github.io/rubychanges/3.0.html#pattern-matching).
Warning[:experimental] = false
require 'package_url'
Warning[:experimental] = true

module Bibliothecary
  module MultiParsers
    module Spdx
      include Bibliothecary::Analyser
      include Bibliothecary::Analyser::TryCache

      # e.g. 'SomeText:' (allowing for leading whitespace)
      WELLFORMED_LINE_REGEX = /^\s*[a-zA-Z]+:/

      # e.g. 'PackageName: (allowing for excessive whitespace)
      PACKAGE_NAME_REGEX = /^\s*PackageName:\s*(.*)/

      # e.g. 'PackageVersion:' (allowing for excessive whitespace)
      PACKAGE_VERSION_REGEX =/^\s*PackageVersion:\s*(.*)/

      # e.g. "ExternalRef: PACKAGE-MANAGER purl (allowing for excessive whitespace)
      PURL_REGEX = /^\s*ExternalRef:\s*PACKAGE[-|_]MANAGER\s*purl\s*(.*)/

      NoEntries = Class.new(StandardError)
      MalformedFile = Class.new(StandardError)

      def self.mapping
        {
          match_extension('.spdx') => {
            kind: 'lockfile',
            parser: :parse_spdx_tag_value,
            ungroupable: true
          }
        }
      end

      def parse_spdx_tag_value(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_spdx_tag_value_file_contents(file_contents)
        end

        raise NoEntries if entries.empty?

        entries[platform_name.to_sym]
      end

      def get_platform(purl_string)
        platform = PackageURL.parse(purl_string).type

        Bibliothecary::PURL_TYPE_MAPPING[platform]
      end

      def parse_spdx_tag_value_file_contents(file_contents)
        entries = {}

        package_name = nil
        package_version = nil
        platform = nil

        file_contents.split("\n").each do |line|
          stripped_line = line.strip

          next if skip_line?(stripped_line)

          raise MalformedFile unless stripped_line.match(WELLFORMED_LINE_REGEX)

          if (match = stripped_line.match(PACKAGE_NAME_REGEX))
            package_name = match[1]
          elsif (match = stripped_line.match(PACKAGE_VERSION_REGEX))
            package_version = match[1]
          elsif (match = stripped_line.match(PURL_REGEX))
            platform ||= get_platform(match[1])
          end

          unless package_name.nil? || package_version.nil? || platform.nil?
            entries[platform.to_sym] ||= []
            entries[platform.to_sym] << {
              name: package_name,
              requirement: package_version,
              type: 'lockfile'
            }

            package_name = package_version = platform = nil
          end
        end

        entries
      end

      def skip_line?(stripped_line)
        # Ignore blank lines and comments
        stripped_line == "" || stripped_line[0] == "#"
      end
    end
  end
end
