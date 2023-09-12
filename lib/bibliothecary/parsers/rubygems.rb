require 'gemnasium/parser'

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
            kind: 'manifest',
            parser: :parse_gemfile,
            related_to: [ 'manifest', 'lockfile' ]
          },
          match_extension(".gemspec") => {
            kind: 'manifest',
            parser: :parse_gemspec,
            related_to: [ 'manifest', 'lockfile' ]
          },
          match_filenames("Gemfile.lock", "gems.locked") => {
            kind: 'lockfile',
            parser: :parse_gemfile_lock,
            related_to: [ 'manifest', 'lockfile' ]
          }
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
            version = match[2].gsub(/\(|\)/,'')
            {
              name: name,
              requirement: version,
              type: 'runtime'
            }
          else
            parse_bundler(file_contents)
          end
        end.compact
      end

      def self.parse_gemfile(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:gemfile, file_contents)

        dependencies_found = parse_ruby_manifest(manifest)
        # patten: gem 'redis', require: %w[redis redis/connection/hiredis]
        dependencies_found_with_new_pattern = extract_gems_by_pattern(
          /gem\s+['"]([^'"]+)['"],\s*require:\s*%w\[([^\]]+)\]/,
          file_contents
        )

        return dependencies_found if dependencies_found_with_new_pattern.empty?
        
        dependencies_found.concat(dependencies_found_with_new_pattern)
                          .group_by { |item| item[:name] }
                          .values.map(&:first)
      end

      def self.parse_gemspec(file_contents, options: {})
        manifest = Gemnasium::Parser.send(:gemspec, file_contents)
        parse_ruby_manifest(manifest)
      end

      def self.parse_bundler(file_contents)
        bundled_with_index = file_contents.lines(chomp: true).find_index { |line| line.match(BUNDLED_WITH) }
        version = file_contents.lines(chomp: true).fetch(bundled_with_index + 1)&.strip

        return nil unless version

        {
          name: 'bundler',
          requirement: version,
          type: 'runtime'
        }
      end
    end
  end
end
