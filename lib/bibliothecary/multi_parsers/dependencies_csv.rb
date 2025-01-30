# frozen_string_literal: true

require "csv"

module Bibliothecary
  module MultiParsers
    module DependenciesCSV
      include Bibliothecary::Analyser
      include Bibliothecary::Analyser::TryCache

      def self.mapping
        {
          match_filename("dependencies.csv") => {
            kind: "lockfile",
            ungroupable: true,
            parser: :parse_dependencies_csv,
          },
        }
      end

      # Processing a CSV file isn't as exact as using a real manifest file,
      # but you can get pretty close as long as the data you're importing
      # is simple.
      class CSVFile
        # Header structures are:
        #
        # <field to fill in for dependency> => {
        #   match: [<regexp of incoming column name to match in priority order, highest priority first>...],
        #   [default]: <optional default value for this field>
        # }
        HEADERS = {
          "platform" => {
            match: [
              /^platform$/i,
            ],
          },
          "name" => {
            match: [
              /^name$/i,
            ],
          },
          # Manifests have versions that can have operators.
          # However, since Bibliothecary only currently supports analyzing a
          # single file as a single thing (either manifest or lockfile)
          # we can't return manifest-y data. Only take the lockfile requirement
          # when processing dependencies.csv for now.
          "requirement" => {
            match: [
              /^(lockfile |)requirement$/i,
              /^version$/i,
            ],
          },
          "type" => {
            default: "runtime",
            match: [
              /^(lockfile |)type$/i,
              /^(manifest |)type$/i,
            ],
          },
        }.freeze

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
              row_data = row[@header_mappings[header]]

              # some column have default data to fall back on
              if row_data
                obj[header.to_sym] = row_data
              elsif info.key?(:default)
                # if the default is nil, don't even add the key to the hash
                obj[header.to_sym] = info[:default] if info[:default]
              else
                # use 1-based index just like the 'csv' std lib, and count the headers as first row.
                raise "Missing required field '#{header}' on line #{idx + 2}."
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
          result = local_lookups.each_with_object({ found: {}, missing: [] }) do |(header, info), obj|
            results = table.headers.each_with_object([]) do |table_header, matches|
              info[:match].each_with_index do |match_regexp, index|
                matches << [table_header, index] if table_header[match_regexp]
              end
            end

            if results.empty?
              # if a header has a default value it's optional
              obj[:missing] << header unless info.key?(:default)
            else
              # select the highest priority header possible
              obj[:found][header] ||= nil
              obj[:found][header] = ([obj[:found][header]] + results).compact.min_by(&:last)
            end
          end

          # strip off the priorities. only one mapping should remain.
          result[:found].transform_values!(&:first)

          result
        end
      end

      def parse_dependencies_csv(file_contents, options: {})
        csv_file = try_cache(options, options[:filename]) do
          raw_csv_file = CSVFile.new(file_contents)
          raw_csv_file.parse!
          raw_csv_file
        end

        csv_file
          .result
          .find_all { |dependency| dependency[:platform] == platform_name.to_s }
          .map do |dep_kvs|
            Dependency.new(
              **dep_kvs, source: options.fetch(:filename, nil)
            )
          end
      end
    end
  end
end
