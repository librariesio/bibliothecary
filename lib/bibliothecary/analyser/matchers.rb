# frozen_string_literal: true

module Bibliothecary
  module Analyser
    module Matchers
      def match_filename(filename, case_insensitive: false)
        if case_insensitive
          ->(path) { path.downcase == filename.downcase || path.downcase.end_with?("/#{filename.downcase}") }
        else
          ->(path) { path == filename || path.end_with?("/#{filename}") }
        end
      end

      def match_filenames(*filenames)
        lambda do |path|
          filenames.any? { |f| path == f } ||
            filenames.any? { |f| path.end_with?("/#{f}") }
        end
      end

      def match_extension(filename, case_insensitive: false)
        if case_insensitive
          ->(path) { path.downcase.end_with?(filename.downcase) }
        else
          ->(path) { path.end_with?(filename) }
        end
      end

      def mapping_entry_match?(matcher, details, info)
        return false unless matcher.call(info.relative_path)
        # we only want to load contents if we don't have them already
        # and there's a content_matcher method to use
        return true if details[:content_matcher].nil?
        # this is the libraries.io case where we won't load all .xml
        # files (for example) just to look at their contents, we'll
        # assume they are not manifests.
        return false if info.contents.nil?

        send(details[:content_matcher], info.contents)
      end

      # this is broken with contents=nil because it can't look at file
      # contents, so skips manifests that are ambiguously a
      # manifest considering only the filename. However, those are
      # the semantics that libraries.io uses since it doesn't have
      # the files locally.
      def match?(filename, contents = nil)
        match_info?(FileInfo.new(nil, filename, contents))
      end

      def match_info?(info)
        first_matching_mapping_details(info).any?
      end

      # Get mapping details for this file, using cache if available.
      # The cache is stored on the FileInfo object to avoid repeated lookups.
      def first_matching_mapping_details(info)
        info.cached_mapping_details(self) do
          mapping
            .find { |matcher, details| mapping_entry_match?(matcher, details, info) }
            &.last || {}
        end
      end
    end
  end
end
