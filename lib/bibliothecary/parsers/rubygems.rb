# frozen_string_literal: true

require "bundler"
require "gemnasium/parser"

module Bibliothecary
  module Parsers
    class Rubygems
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::BundlerLikeManifest

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/
      BUNDLED_WITH = /BUNDLED WITH/

      def self.mapping
        {
          match_filenames("Gemfile", "gems.rb") => {
            kind: "manifest",
            parser: :parse_gemfile,
            related_to: %w[manifest lockfile],
          },
          match_extension(".gemspec") => {
            kind: "manifest",
            parser: :parse_gemspec,
            related_to: %w[manifest lockfile],
          },
          match_filenames("Gemfile.lock", "gems.locked") => {
            kind: "lockfile",
            parser: :parse_gemfile_lock,
            related_to: %w[manifest lockfile],
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_gemfile_lock(file_contents, options: {})
        lockfile = Bundler::LockfileParser.new(file_contents)
        source = options.fetch(:filename, nil)

        dependencies = lockfile.specs.map do |spec|
          Dependency.new(
            platform: platform_name,
            name: spec.name,
            requirement: spec.version.to_s,
            type: "runtime",
            source: source
          )
        end

        bundler_version = lockfile.bundler_version
        if bundler_version
          dependencies << Dependency.new(
            platform: platform_name,
            name: "bundler",
            requirement: bundler_version.to_s,
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_gemfile(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:gemfile, file_contents)
        dependencies = parse_ruby_manifest(manifest, platform_name, options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_gemspec(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:gemspec, file_contents)
        dependencies = parse_ruby_manifest(manifest, platform_name, options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_bundler(file_contents, source = nil)
        bundled_with_index = file_contents.lines(chomp: true).find_index { |line| line.match(BUNDLED_WITH) }
        version = file_contents.lines(chomp: true).fetch(bundled_with_index + 1)&.strip

        return nil unless version

        Dependency.new(
          name: "bundler",
          requirement: version,
          type: "runtime",
          source: source,
          platform: platform_name
        )
      end
    end
  end
end
