require 'gemnasium/parser'

module Bibliothecary
  module Parsers
    class Rubygems
      include Bibliothecary::Analyser

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'.freeze
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/

      def self.parse(filename, file_contents)
        if filename.match(/^Gemfile$|^gems\.rb$/)
          manifest = Gemnasium::Parser.send(:gemfile, file_contents)
          parse_manifest(manifest)
        elsif filename.match(/[A-Za-z0-9_-]+\.gemspec$/)
          manifest = Gemnasium::Parser.send(:gemspec, file_contents)
          parse_manifest(manifest)
        elsif filename.match(/^Gemfile\.lock$|^gems\.locked$/)
          parse_gemfile_lock(file_contents)
        else
          []
        end
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
