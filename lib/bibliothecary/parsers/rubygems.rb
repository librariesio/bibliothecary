require 'gemnasium/parser'

module Bibliothecary
  module Parsers
    class Rubygems
      include Bibliothecary::Analyser

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'.freeze
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/

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

      def self.parse_gemfile_lock(manifest)
        manifest.lines(chomp: true).map do |line|
          match = line.match(NAME_VERSION_4)
          next unless match
          name = match[1]
          version = match[2].gsub(/\(|\)/,'')
          {
            name: name,
            requirement: version,
            type: 'runtime'
          }
        end.compact
      end

      def self.parse_gemfile(file_contents)
        manifest = Gemnasium::Parser.send(:gemfile, file_contents)
        parse_ruby_manifest(manifest)
      end

      def self.parse_gemspec(file_contents)
        manifest = Gemnasium::Parser.send(:gemspec, file_contents)
        parse_ruby_manifest(manifest)
      end
    end
  end
end
