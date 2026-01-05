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
        source = options.fetch(:filename, nil)
        dependencies = []

        # Process line by line to match gem specs
        # Gems are at 4 spaces indentation: "    name (version)" or "    name (version-platform)"
        file_contents.each_line do |line|
          # Normalize line endings
          line = line.chomp.gsub(/\r$/, "")

          # Match exactly 4 spaces followed by gem name and version
          next unless (match = line.match(NAME_VERSION_4))

          name, version, _platform = match.captures
          next if name.nil? || name.empty?

          dependencies << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: version,
            type: "runtime",
            source: source
          )
        end

        # Extract bundler version from BUNDLED WITH section
        if (bundler_dep = parse_bundler(file_contents, source))
          dependencies << bundler_dep
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
        return nil unless bundled_with_index

        version = file_contents.lines(chomp: true).fetch(bundled_with_index + 1, nil)&.strip
        return nil unless version && !version.empty?

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
