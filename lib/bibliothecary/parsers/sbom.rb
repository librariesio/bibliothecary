# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    # The Sbom parser is a special case and does not represent a single platform. It
    # is used for reading *all* the dependencies in an SPDX or CycloneDX SBOM instead
    # of a single platform.
    class Sbom
      include Bibliothecary::Analyser

      def self.mapping
        # All the mappings are provided by CycloneDX and Spdx
        {}
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)
    end
  end
end
