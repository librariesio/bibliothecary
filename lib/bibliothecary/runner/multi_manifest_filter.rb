module Bibliothecary
  class Runner
    class MultiManifestFilter
      # Wrap up a file analysis for easier validity testing
      class FileAnalysis
        def initialize(file_analysis)
          @file_analysis = file_analysis
        end

        # Determine if we should skip this file analysis when processing
        # @return [Boolean] True if we should skip processing
        def skip?
          !@file_analysis ||
          !@file_analysis[:dependencies] ||
          @file_analysis[:dependencies].empty?
        end
      end

      def initialize(path:, related_files_info_entries:, runner:)
        @path = path
        @related_files_info_entries = related_files_info_entries
        @runner = runner
      end

      # Standalone multi manifest files should *always* be treated as lockfiles,
      # since there's no human-written manifest file to go with them.
      def files_to_check
        @files_to_check ||= @related_files_info_entries.each_with_object({}) do |files_info, all|
          files_info.lockfiles.each do |file|
            all[file] ||= 0
            all[file] += 1
          end
        end
      end

      def results
        partition_file_entries!

        (no_lockfile_results + single_file_results + multiple_file_results).uniq
      end

      def no_lockfile_results
        @no_lockfile_results ||= @related_files_info_entries.find_all { |rfi| rfi.lockfiles.empty? }
      end

      def single_file_results
        @single_file_results ||= @single_file_entries.map do |file|
          @related_files_info_entries.find { |rfi| rfi.lockfiles.include?(file) }
        end
      end

      def multiple_file_results
        return @multiple_file_results if @multiple_file_results

        @multiple_file_results = []

        each_analysis_and_rfis do |analysis, rfis_for_file|
          rfis_for_file.each do |rfi|
            file_analysis = FileAnalysis.new(
              analysis.find { |a| a[:platform] == rfi.platform }
            )

            next if file_analysis.skip?

            @multiple_file_results << rfi
          end
        end

        @multiple_file_results
      end

      def each_analysis_and_rfis
        @multiple_file_entries.each do |file|
          # Remove any Byte Order Marks so JSON, etc don't fail while parsing them.
          contents = File.read(File.join(@path, file)).sub(/^\xEF\xBB\xBF/, '')
          analysis = @runner.analyse_file(file, contents)
          rfis_for_file = @related_files_info_entries.find_all { |rfi| rfi.lockfiles.include?(file) }

          yield analysis, rfis_for_file
        end
      end

      def partition_file_entries!
        @single_file_entries, @multiple_file_entries = files_to_check.partition { |_file, count| count == 1  }

        @single_file_entries = @single_file_entries.map(&:first)
        @multiple_file_entries = @multiple_file_entries.map(&:first)
      end
    end
  end
end

