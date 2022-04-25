require 'csv'

module Bibliothecary
  module Parsers
    class Generic
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("dependencies.csv") => {
            kind: 'lockfile',
            parser: :parse_lockfile
          }
        }
      end

      def self.parse_lockfile(file_contents, options: {})
        table = CSV.parse(file_contents, headers: true)

        required_headers = ["platform", "name", "requirement"]
        missing_headers = required_headers - table.headers
        raise "Missing headers #{missing_headers} in CSV" unless missing_headers.empty?

        table.map.with_index do |row, idx|
          line = idx + 2 # use 1-based index just like the 'csv' std lib, and count the headers as first row.
          required_headers.each do |h|
            raise "missing field '#{h}' on line #{line}" if row[h].nil? || row[h].empty?
          end
          {
            platform: row['platform'],
            name: row['name'],
            requirement: row['requirement'],
            type: row.fetch('type', 'runtime'),
          }
        end
      end
    end
  end
end
