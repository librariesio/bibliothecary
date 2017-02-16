require 'gemnasium/parser'

module Bibliothecary
  module Parsers
    class Rubygems
      include Bibliothecary::Analyser

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'.freeze
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/

      def self.mapping
        {
          /^Gemfile$|^gems\.rb$/ => :parse_gemfile,
          /[A-Za-z0-9_-]+\.gemspec$/ => :parse_gemspec,
          /^Gemfile\.lock$|^gems\.locked$/ => :parse_gemfile_lock
        }
      end

      def self.parse_gemfile_lock(manifest)
        manifest.split("\n").map do |line|
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
        parse_manifest(manifest)
      end

      def self.parse_gemspec(file_contents)
        manifest = Gemnasium::Parser.send(:gemspec, file_contents)
        parse_manifest(manifest)
      end

      def self.parse_manifest(manifest)
        manifest.dependencies.inject([]) do |deps, dep|
          deps.push({
            name: dep.name,
            requirement: dep.requirement.to_s,
            type: dep.type
          })
        end.uniq
      end
    end
  end
end
