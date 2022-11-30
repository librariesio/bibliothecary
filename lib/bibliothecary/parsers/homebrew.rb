module Bibliothecary
  module Parsers
    class Homebrew
      include Bibliothecary::Analyser

      HOMEBREW_REGEXP = /^brew\s(.+),?\s?/

      def self.mapping
        {
          match_filename("Brewfile", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_brewfile,
            related_to: ['lockfile']
          },
          match_filename("Brewfile.lock.json", case_insensitive: true) => {
            kind: 'lockfile',
            parser: :parse_brewfile_lock_json,
            related_to: ['manifest']
          }
        }
      end

      def self.parse_brewfile(file_contents, options: {})
        deps = []
        file_contents.split("\n").each do |line|
          match = line.gsub(/(\#(.*))/, '').match(HOMEBREW_REGEXP)
          next unless match
          deps << {
            name: match[1].strip.gsub('"', '').gsub("'", ''),
            requirement: '*',
            type: 'runtime'
          }
        end
        deps
      end

      def self.parse_brewfile_lock_json(file_contents, options: {})
        json = JSON.parse file_contents
        json['entries']['brew'].map do |k,v|
          {
            name: k,
            requirement: v['version'],
            type: 'runtime'
          }
        end
      end
    end
  end
end
