require "bundler"
require "gemnasium/parser"

module Bibliothecary
  module Parsers
    class Rubygems
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::BundlerLikeManifest

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'.freeze
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/
      BUNDLED_WITH = /BUNDLED WITH/

      def self.mapping
        {
          match_filenames("Gemfile", "gems.rb") => {
            kind: "manifest",
            parser: :parse_gemfile,
            related_to: [ "manifest", "lockfile" ],
          },
          match_extension(".gemspec") => {
            kind: "manifest",
            parser: :parse_gemspec,
            related_to: [ "manifest", "lockfile" ],
          },
          match_filenames("Gemfile.lock", "gems.locked") => {
            kind: "lockfile",
            parser: :parse_gemfile_lock,
            related_to: [ "manifest", "lockfile" ],
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_gemfile_lock(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        lockfile = Bundler::LockfileParser.new(file_contents)
      
        dependencies = lockfile.specs.map do |spec|
          {
            name: spec.name,
            requirement: spec.version.to_s,
            type: "runtime",
          }
        end
      
        bundler_version = lockfile.bundler_version
        if bundler_version
          dependencies << {
            name: "bundler",
            requirement: bundler_version.to_s,
            type: "runtime",
          }
        end
      
        dependencies
      end

      def self.parse_gemfile(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = Gemnasium::Parser.send(:gemfile, file_contents)
        parse_ruby_manifest(manifest)
      end

      def self.parse_gemspec(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        manifest = Gemnasium::Parser.send(:gemspec, file_contents)
        parse_ruby_manifest(manifest)
      end

      def self.parse_bundler(file_contents)
        bundled_with_index = file_contents.lines(chomp: true).find_index { |line| line.match(BUNDLED_WITH) }
        version = file_contents.lines(chomp: true).fetch(bundled_with_index + 1)&.strip

        return nil unless version

        {
          name: "bundler",
          requirement: version,
          type: "runtime",
        }
      end
    end
  end
end
