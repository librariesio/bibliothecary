# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Nuget
      class NugetRequirement
        # Regular expressions for different NuGet version range patterns
        MINOR_WILDCARD_REGEXP = /^(\d+)\.\*$/                         # 1.* - minor wildcard
        PATCH_WILDCARD_REGEXP = /^(\d+)\.(\d+)\.\*$/                  # 1.2.* - patch wildcard
        FULL_WILDCARD_REGEXP = /^\*$/                                 # * - full wildcard
        MINIMUM_VERSION_REGEXP = /^\d+\.\d+.*$/                       # Minimum version like "1.0"
        INCLUSIVE_LOWER_BOUND_REGEXP = /^\[([^,\]]+),\)$/             # [1.0,) - inclusive lower bound, no upper
        EXCLUSIVE_LOWER_BOUND_REGEXP = /^\(([^,\]]+),\)$/             # (1.0,) - exclusive lower bound, no upper
        EXACT_VERSION_REGEXP = /^\[([^,\]]+)\]$/                      # [1.0] - exact version
        INCLUSIVE_UPPER_BOUND_REGEXP = /^\(,([^,\]]+)\]$/             # (,1.0] - no lower, inclusive upper bound
        EXCLUSIVE_UPPER_BOUND_REGEXP = /^\(,([^,\]]+)\)$/             # (,1.0) - no lower, exclusive upper bound
        INCLUSIVE_RANGE_REGEXP = /^\[([^,\]]+),([^,\]]+)\]$/          # [1.0,2.0] - inclusive range
        EXCLUSIVE_RANGE_REGEXP = /^\(([^,\]]+),([^,\]]+)\)$/          # (1.0,2.0) - exclusive range
        INCLUSIVE_LOWER_EXCLUSIVE_UPPER_REGEXP = /^\[([^,\]]+),([^,\]]+)\)$/ # [1.0,2.0) - inclusive lower, exclusive upper
        EXCLUSIVE_LOWER_INCLUSIVE_UPPER_REGEXP = /^\(([^,\]]+),([^,\]]+)\]$/ # (1.0,2.0] - exclusive lower, inclusive upper

        # Converts NuGet version range syntax to a semver requirement syntax
        # supported by the semantic_range gem (https://github.com/librariesio/semantic_range).
        # Nuget docs: https://learn.microsoft.com/en-us/nuget/concepts/package-versioning#version-ranges
        #
        # @param requirement [String] The NuGet version range string
        # @return [String] The converted semver requirement string
        # @raise [ArgumentError] If the requirement format is invalid
        def self.convert_to_semver_requirement(requirement)
          case requirement
          when MINOR_WILDCARD_REGEXP
            "~> #{::Regexp.last_match(1)}.0"
          when PATCH_WILDCARD_REGEXP
            ">= #{::Regexp.last_match(1)}.0"
          when FULL_WILDCARD_REGEXP, nil
            ">= 0"
          when MINIMUM_VERSION_REGEXP
            ">= #{requirement}"
          when INCLUSIVE_LOWER_BOUND_REGEXP
            ">= #{::Regexp.last_match(1)}"
          when EXCLUSIVE_LOWER_BOUND_REGEXP
            "> #{::Regexp.last_match(1)}"
          when EXACT_VERSION_REGEXP
            ::Regexp.last_match(1)
          when INCLUSIVE_UPPER_BOUND_REGEXP
            "<= #{::Regexp.last_match(1)}"
          when EXCLUSIVE_UPPER_BOUND_REGEXP
            "< #{::Regexp.last_match(1)}"
          when INCLUSIVE_RANGE_REGEXP
            ">= #{::Regexp.last_match(1)} <= #{::Regexp.last_match(2)}"
          when EXCLUSIVE_RANGE_REGEXP
            "> #{::Regexp.last_match(1)} < #{::Regexp.last_match(2)}"
          when INCLUSIVE_LOWER_EXCLUSIVE_UPPER_REGEXP
            ">= #{::Regexp.last_match(1)} < #{::Regexp.last_match(2)}"
          when EXCLUSIVE_LOWER_INCLUSIVE_UPPER_REGEXP
            "> #{::Regexp.last_match(1)} <= #{::Regexp.last_match(2)}"
          else
            raise ArgumentError, "Invalid NuGet version range format: #{requirement}"
          end
        end
      end
    end
  end
end
