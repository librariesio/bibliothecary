# frozen_string_literal: true

module Bibliothecary
  class Runner
    class MultiManifestFilter
      def initialize(path:, related_files_info_entries:, runner:)
        raise "Bibliothecary::Runner::MultiManifestFilter has been removed in bibliothecary 15.0.0. Since MultiParsers now act like Parsers, there is no replacement or need for it."
      end
    end
  end
end
