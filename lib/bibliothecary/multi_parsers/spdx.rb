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

      NoEntries = Class.new(StandardError)
      MalformedFile = Class.new(StandardError)

      # If a purl type (key) exists, it will be used in a manifest for
      # the key's value. If not, it's ignored.
      #
      # https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst
      PURL_TYPE_MAPPING = {
        "golang" => :go,
        "maven" => :maven,
        "npm" => :npm,
        "cargo" => :cargo,
        "composer" => :packagist,
        "conda" => :conda,
        "cran" => :cran,
        "gem" => :rubygems,
        "hackage" => :hackage,
        "hex" => :hex,
        "nuget" => :nuget,
        "pypi" => :pypi,
        "swift" => :swift_pm
      }

      def self.mapping
        {
          match_extension('.spdx') => {
            kind: 'manifest',
            parser: :parse_spdx,
            ungroupable: true
          },
        }
      end

      def parse_spdx(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_file_contents(file_contents)
        end

        raise NoEntries if entries.empty?

        entries[platform_name.to_sym]
      end

      def get_platform(spdx_id)
        PURL_TYPE_MAPPING.values.find { |mapping| !spdx_id.index(mapping.to_s).nil?}
      end

      def parse_file_contents(file_contents)
        entries = {}

        package_name = nil
        package_version = nil
        platform = nil

        file_contents.split("\n").each do |line|
          next if line.strip == ""

          raise MalformedFile unless line.match(/^[a-zA-Z]+: \S+/)

          if !line.index("PackageName:").nil?
            package_name = line.split("PackageName: ")[1]

          elsif !line.index("PackageVersion:").nil?
            package_version = line.split("PackageVersion: ")[1]
          elsif !line.index("SPDXID:").nil?
            platform = get_platform(line.split("SPDXID: ")[1])
          end

          unless package_name.nil? || package_version.nil? || platform.nil?
            entries[platform_name.to_sym] ||= []
            entries[platform_name.to_sym] << {
              name: package_name,
              requirement: package_version,
              type: 'lockfile'
            }

            package_name = package_version = platform = nil
          end
        end

        entries
      end
    end
  end
end
