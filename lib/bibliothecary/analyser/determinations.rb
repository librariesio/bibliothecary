# frozen_string_literal: true

module Bibliothecary
  module Analyser
    module Determinations
      # calling this with contents=nil can produce less-informed
      # results, but kept for back compat
      def determine_kind(filename, contents = nil)
        determine_kind_from_info(FileInfo.new(nil, filename, contents))
      end

      def determine_kind_from_info(info)
        first_matching_mapping_details(info)
          .fetch(:kind, nil)
      end

      # calling this with contents=nil can produce less-informed
      # results, but kept for back compat
      def determine_can_have_lockfile(filename, contents = nil)
        determine_can_have_lockfile_from_info(FileInfo.new(nil, filename, contents))
      end

      def determine_can_have_lockfile_from_info(info)
        first_matching_mapping_details(info)
          .fetch(:can_have_lockfile, true)
      end

      def groupable?(info)
        # More package managers are groupable than ungroupable, but the methods
        # to get this information should be positive.
        !first_matching_mapping_details(info).fetch(:ungroupable, false)
      end
    end
  end
end
