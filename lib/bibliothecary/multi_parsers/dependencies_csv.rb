require 'csv'

module Bibliothecary
  module MultiParsers
    module DependenciesCSV
      include Bibliothecary::Analyser
      include Bibliothecary::Analyser::TryCache

      def self.mapping
        {
          match_filename('dependencies.csv') => {
            kind: 'lockfile',
            parser: :parse_dependencies_csv
          }
        }
      end

      class CSVFile
        REQUIRED_HEADERS = ["platform", "name", "requirement"]
        OPTIONAL_HEADERS = {
          "type" => { default: "runtime" }
        }

        attr_reader :result

        def initialize(file_contents)
          @file_contents = file_contents
          @result = nil
        end

        def parse!
          table = parse_and_validate_csv_file

          @result = table.map.with_index do |row, idx|
            row_result = REQUIRED_HEADERS.each_with_object({}) do |header, obj|
              if row[header].nil? || row[header].empty?
                line = idx + 2 # use 1-based index just like the 'csv' std lib, and count the headers as first row.
                raise "Missing required field '#{header}' on line #{line}.h"
              end

              obj[header.to_sym] = row[header]
            end

            row_result = OPTIONAL_HEADERS.each_with_object(row_result) do |(header, info), obj|
              if row[header]
                obj[header.to_sym] = row[header]
              elsif info[:default]
                obj[header.to_sym] = info[:default]
              end
            end

            row_result
          end
        end

        private

        def parse_and_validate_csv_file
          table = CSV.parse(@file_contents, headers: true)

          missing_headers = REQUIRED_HEADERS - table.headers
          raise "Missing required headers #{missing_headers.join(', ')} in CSV. Check to make sure header names are all lowercase." unless missing_headers.empty?

          table
        end
      end

      def parse_dependencies_csv(file_contents, options: {})
        csv_file = try_cache(options, options[:filename]) do
          raw_csv_file = CSVFile.new(file_contents)
          raw_csv_file.parse!
          raw_csv_file
        end

        csv_file.result.find_all do |dependency|
          dependency[:platform] == platform_name.to_s
        end
      end
    end
  end
end
