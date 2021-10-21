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

      def self.parse_lockfile(file_contents)
        table = CSV.parse(file_contents, headers: true)

        required_headers = ["platform", "name", "requirement"]
        missing_headers = []
        for h in required_headers
          missing_headers.push(h) unless table.headers.include?(h)
        end
        raise "Missing headers #{missing_headers} in CSV" unless missing_headers.empty?

        deps = []
        line = 1
        for row in table
          for h in required_headers
            raise "missing field '#{h}' on line #{line}" if row[h].empty?
          end
          line += 1
          deps.push({
                      platform: row['platform'],
                      name: row['name'],
                      requirement: row['requirement'],
                      type: row.fetch('type', 'runtime'),
                    })
        end
        deps
      end
    end
  end
end
