# frozen_string_literal: true

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
        file_contents.lines(chomp: true).map do |line|
          match = line.match(NAME_VERSION_4)
          bundler_match = line.match(BUNDLED_WITH)
          next unless match || bundler_match

          if match
            name = match[1]
            version = match[2].gsub(/\(|\)/, "")
            Dependency.new(
              name:,
              requirement: version,
              type: "runtime",
              source: options.fetch(:filename, nil)
            )
          else
            parse_bundler(file_contents, options.fetch(:filename, nil))
          end
        end.compact
      end

      def self.parse_gemfile(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:gemfile, file_contents)
        parse_ruby_manifest(manifest, options.fetch(:filename, nil))
      end

      def self.parse_gemspec(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:gemspec, file_contents)
        parse_ruby_manifest(manifest, options.fetch(:filename, nil))
      end

      def self.parse_bundler(file_contents, source = nil)
        bundled_with_index = file_contents.lines(chomp: true).find_index { |line| line.match(BUNDLED_WITH) }
        version = file_contents.lines(chomp: true).fetch(bundled_with_index + 1)&.strip

        return nil unless version

        Dependency.new(
          name: "bundler",
          requirement: version,
          type: "runtime",
          source:
        )
      end
    end
  end
end
