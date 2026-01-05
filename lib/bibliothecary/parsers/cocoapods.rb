# frozen_string_literal: true

require "gemnasium/parser"
require "yaml"

module Bibliothecary
  module Parsers
    class CocoaPods
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::BundlerLikeManifest

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/

      def self.mapping
        {
          match_filename("Podfile") => {
            kind: "manifest",
            parser: :parse_podfile,
          },
          match_extension(".podspec") => {
            kind: "manifest",
            parser: :parse_podspec,
            can_have_lockfile: false,
          },
          match_filename("Podfile.lock") => {
            kind: "lockfile",
            parser: :parse_podfile_lock,
          },
          match_extension(".podspec.json") => {
            kind: "manifest",
            parser: :parse_json_manifest,
            can_have_lockfile: false,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_podfile_lock(file_contents, options: {})
        source = options.fetch(:filename, nil)
        dependencies = []

        # Match pod entries: "  - Name (version)" or "  - Name/Subspec (version)"
        # Only process lines in PODS section (before DEPENDENCIES section)
        pods_section = file_contents.split(/^DEPENDENCIES:/)[0]
        pods_section.scan(/^  - ([^\s(]+(?:\/[^\s(]+)?)\s+\(([^)]+)\)/) do |name, version|
          # Take only the base package name (before any /)
          base_name = name.split("/").first
          dependencies << Dependency.new(
            platform: platform_name,
            name: base_name,
            requirement: version,
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_podspec(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:podspec, file_contents)
        dependencies = parse_ruby_manifest(manifest, platform_name, options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_podfile(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:podfile, file_contents)
        dependencies = parse_ruby_manifest(manifest, platform_name, options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_json_manifest(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        dependencies = manifest["dependencies"].inject([]) do |deps, dep|
          deps.push(Dependency.new(
                      platform: platform_name,
                      name: dep[0],
                      requirement: dep[1],
                      type: "runtime",
                      source: options.fetch(:filename, nil)
                    ))
        end.uniq
        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
