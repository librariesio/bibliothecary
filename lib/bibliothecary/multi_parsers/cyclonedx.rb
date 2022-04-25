require 'json'
require 'ox'

# packageurl-ruby uses pattern-matching (https://docs.ruby-lang.org/en/2.7.0/NEWS.html#label-Pattern+matching)
# which warns a whole bunch in Ruby 2.7 as being an experimental feature, but has
# been accepted in Ruby 3.0 (https://rubyreferences.github.io/rubychanges/3.0.html#pattern-matching).
Warning[:experimental] = false
require 'package_url'
Warning[:experimental] = true

module Bibliothecary
  module MultiParsers
    module CycloneDX
      include Bibliothecary::Analyser
      include Bibliothecary::Analyser::TryCache

      NoComponents = Class.new(StandardError)

      class ManifestEntries
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

        attr_reader :manifests

        def initialize
          @manifests = {}
        end

        def <<(purl)
          mapping = PURL_TYPE_MAPPING[purl.type]
          return unless mapping

          @manifests[mapping] ||= Set.new
          @manifests[mapping] << {
            name: self.class.full_name_for_purl(purl),
            requirement: purl.version,
            type: 'lockfile'
          }
        end

        def [](key)
          @manifests[key]&.to_a
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
      end

      def self.mapping
        {
          match_filename('cyclonedx.json') => {
            kind: 'lockfile',
            parser: :parse_cyclonedx_json
          },
          match_filename('cyclonedx.xml') => {
            kind: 'lockfile',
            parser: :parse_cyclonedx_xml
          }
        }
      end

      def parse_cyclonedx_json(file_contents, options: {})
        manifest = nil

        manifest = try_cache(options, options[:filename]) do
          JSON.parse(file_contents)
        end

        raise NoComponents unless manifest["components"]

        entries = ManifestEntries.new

        manifest["components"].each_with_object(entries) do |component, obj|
          next unless component["purl"]

          purl = PackageURL.parse(component["purl"])

          obj << purl
        end

        entries[platform_name.to_sym]
      end

      def parse_cyclonedx_xml(file_contents, options: {})
        manifest = try_cache(options, options[:filename]) do
          Ox.parse(file_contents)
        end

        root = manifest
        if root.respond_to?(:bom)
          root = root.bom
        end

        raise NoComponents unless root.locate('components').first

        entries = ManifestEntries.new

        root.locate('components/*').each_with_object(entries) do |component, obj|
          purl_node = component.locate("purl").first

          next unless purl_node

          purl = PackageURL.parse(purl_node.text)

          obj << purl
        end

        entries[platform_name.to_sym]
      end
    end
  end
end
