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
        attr_reader :manifests

        def initialize(parse_queue:)
          @manifests = {}

          # Instead of recursing, we'll work through a queue of components
          # to process, letting the different parser add components to the
          # queue however they need to  pull them from the source document.
          @parse_queue = parse_queue.dup
        end

        def <<(purl)
          mapping = Bibliothecary::PURL_TYPE_MAPPING[purl.type]
          return unless mapping

          @manifests[mapping] ||= Set.new
          @manifests[mapping] << {
            name: self.class.full_name_for_purl(purl),
            requirement: purl.version,
            type: 'lockfile'
          }
        end

        # Iterates over each manifest entry in the parse_queue, and accepts a block which will
        # be called on each component. The block has two jobs: 1) add more sub-components
        # to parse (if they exist), and 2) return the components purl.
        def parse!(&block)
          while @parse_queue.length > 0
            component = @parse_queue.shift

            purl_text = block.call(component, @parse_queue)

            next unless purl_text

            purl = PackageURL.parse(purl_text)

            self << purl
          end
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
            parser: :parse_cyclonedx_json,
            ungroupable: true
          },
          match_filename('cyclonedx.xml') => {
            kind: 'lockfile',
            parser: :parse_cyclonedx_xml,
            ungroupable: true
          }
        }
      end

      def parse_cyclonedx_json(file_contents, options: {})
        manifest = nil

        manifest = try_cache(options, options[:filename]) do
          JSON.parse(file_contents)
        end

        raise NoComponents unless manifest["components"]

        entries = ManifestEntries.new(parse_queue: manifest["components"])

        entries.parse! do |component, parse_queue|
          parse_queue.concat(component["components"]) if component["components"]

          component["purl"]
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

        entries = ManifestEntries.new(parse_queue: root.locate('components/*'))

        entries.parse! do |component, parse_queue|
          # #locate returns an empty array if nothing is found, so we can
          # always safely concatenate it to the parse queue.
          parse_queue.concat(component.locate('components/*'))

          component.locate("purl").first&.text
        end

        entries[platform_name.to_sym]
      end
    end
  end
end
