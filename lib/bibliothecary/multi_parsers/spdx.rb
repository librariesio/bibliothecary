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

      class ManifestEntries
        attr_reader :manifests

        def initialize(parse_queue:)
          @manifests = {}

          # Instead of recursing, we'll work through a queue of components
          # to process, letting the different parser add components to the
          # queue however they need to  pull them from the source document.
          @parse_queue = parse_queue.dup
        end

        def <<(purl)
          mapping = PURL_TYPE_MAPPING[purl.type]
          return unless mapping

          @manifests[mapping] ||= Set.new
          @manifests[mapping] << {
            name: self.class.full_name_for_purl(purl),
            requirement: purl.version,
            # not sure if this should be 'lockfile' or 'manifest'
            type: 'lockfile'
          }
        end

        # Iterates over each manifest entry in the parse_queue, and accepts and
        # returns a package URL
        def parse!
          while @parse_queue.length > 0
            purl_text = @parse_queue.shift
            purl = PackageURL.parse(purl_text)

            self << purl
          end
        end

        # @return [String] The properly namespaced package name
        def self.full_name_for_purl(purl)
          parts = [purl.namespace, purl.name].compact

          case purl.type
          when "maven"
            parts.join(':')
          else
            parts.join('/')
          end
        end

        def [](key)
          @manifests[key]&.to_a
        end
      end

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

          # unless line.index("ExternalRef: PACKAGE-MANAGER purl ").nil?
          #   purl_text = line.split("ExternalRef: PACKAGE-MANAGER purl ")[1]

          #   purls.push(purl_text)
          # end
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
              # not sure if this should be 'lockfile' or 'manifest'
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
