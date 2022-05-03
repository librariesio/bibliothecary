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

      # Processing a CVS file isn't as exact as using a real manifest file,
      # but you can get pretty close as long as the data you're importing
      # is simple.
      class CSVFile
        # Header structures are:
        #
        # <field to fill in for dependency> => {
        #   match: [<regexp of incoming column name to match in priority order>...],
        #   [default]: <optional default value for this field>
        # }
        HEADERS = {
          "platform" => {
            match: [
              /^platform$/i
            ]
          },
          "name" => {
            match: [
              /^name$/i
            ]
          },
          # The "requirement" column in this case is going to want exact
          # versions. Prefer those over requirements, and don't use the
          # Lockfile Requirement column from CVS exports.
          "requirement" => {
            match: [
              /^(manifest |)requirement$/i,
              /^version$/i,
            ],
            # strip anything from the front that doesn't look like a version number.
            process: lambda do |value|
              value.gsub(/^[^\dvV]*/, '')
            end
          },
          "lockfile_requirement" => {
            match: [
              /^lockfile requirement$/i,
            ],
            default: nil
          },
          "type" => {
            default: "runtime",
            match: [
              /^(lockfile |)type$/i,
              /^(manifest |)type$/i
            ]
          }
        }

        attr_reader :result

        def initialize(file_contents)
          @file_contents = file_contents

          @result = nil

          # A Hash of "our field name" => ["header in CSV file", "lower priority header in CSV file"]
          @header_mappings = {}
        end

        def parse!
          table = parse_and_validate_csv_file

          @result = table.map.with_index do |row, idx|
            HEADERS.each_with_object({}) do |(header, info), obj|
              # find the first non-empty field in the row for this header, or nil if not found
              row_data = @header_mappings[header]&.map { |mapping| row[mapping] }&.compact&.first

              row_data = info[:process].call(row_data) if info[:process]

              # some columsn have default data to fall back on
              if info.has_key?(:default)
                if row_data
                  obj[header.to_sym] = row_data
                # if the default is nil, don't even add the key to the hash
                elsif info[:default]
                  obj[header.to_sym] = info[:default]
                end
              else
                if row_data.nil? || row_data.empty?
                  # use 1-based index just like the 'csv' std lib, and count the headers as first row.
                  raise "Missing required field '#{header}' on line #{idx + 2}."
                end

                obj[header.to_sym] = row_data
              end
            end
          end
        end

        private

        def parse_and_validate_csv_file
          table = CSV.parse(@file_contents, headers: true)

          header_examination_results = map_table_headers_to_local_lookups(table, HEADERS)
          unless header_examination_results[:missing].empty?
            raise "Missing required headers #{header_examination_results[:missing].join(', ')} in CSV. Check to make sure header names are all lowercase."
          end
          @header_mappings = header_examination_results[:found]

          table
        end

        def map_table_headers_to_local_lookups(table, local_lookups)
          local_lookups.each_with_object({ found: {}, missing: [] }) do |(header, info), obj|
            results = table.headers.find_all { |table_header| info[:match].any? { |match_regexp| table_header[match_regexp] } }

            if results.empty?
              # if a header has a default value it's optional
              obj[:missing] << header unless info.has_key?(:default)
            else
              # select every possible header that can match this field
              obj[:found][header] ||= []
              obj[:found][header].concat(results)
            end
          end
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
