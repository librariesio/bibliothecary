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

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_brewfile(file_contents, options: {})
        source = options.fetch(:filename, 'Brewfile')
        deps = []
        file_contents.split("\n").each do |line|
          match = line.gsub(/(\#(.*))/, '').match(HOMEBREW_REGEXP)
          next unless match
          deps << Bibliothecary::Dependency.new(
            platform: platform_name,
            name: match[1].strip.gsub('"', '').gsub("'", ''),
            requirement: '*',
            type: 'runtime',
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      def self.parse_brewfile_lock_json(file_contents, options: {})
        source = options.fetch(:filename, 'Brewfile.lock.json')
        json = JSON.parse file_contents
        deps = json['entries']['brew'].map do |k,v|
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: k,
            requirement: v['version'],
            type: 'runtime',
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
