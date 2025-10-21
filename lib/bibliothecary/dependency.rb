# frozen_string_literal: true

module Bibliothecary
  # Dependency represents a single unique dependency that was parsed out of a manifest.
  #
  # @attr_reader [String] name The name of the package, e.g. "ansi-string-colors"
  # @attr_reader [String] requirement The version requirement of the release, e.g. "1.0.0" or "^1.0.0"
  # @attr_reader [String] platform The platform of the package, e.g. "maven". This is optional because
  #   it's implicit in most parser results, and the analyzer returns the platform name itself. One
  #   exception are multi-parsers like DependenciesCSV, because they may return deps from multiple platforms.
  #   Bibliothecary could start returning this field for *all* deps in future, and make it required. (default: nil)
  # @attr_reader [String] type The type or scope of dependency, e.g. "runtime" or "test". In some ecosystems a
  #   default may be set and in other ecosystems it may make sense to return nil when not found.
  # @attr_reader [Boolean] direct Is this dependency a direct dependency (vs transitive dependency)? (default: nil)
  # @attr_reader [Boolean] deprecated Is this dependency deprecated? (default: nil)
  # @attr_reader [Boolean] local Is this dependency local? (default: nil)
  # @attr_reader [Boolean] optional Is this dependency optional? (default: nil)
  # @attr_reader [String] original_name The original name used to require the dependency, for cases
  #   where it did not match the resolved name. This can be used for features like aliasing.
  # @attr_reader [String] original_requirement The original requirement used to require the dependency,
  #   for cases where it did not match the resolved name. This can be used for features like aliasing.
  # @source [String] source An optional string to store the location of the manifest that contained this
  #   dependency, e.g. "src/package.json".
  class Dependency
    FIELDS = %i[
      name
      requirement
      original_requirement
      platform
      type
      direct
      deprecated
      local
      optional
      original_name
      source
    ].freeze

    attr_reader(*FIELDS)

    def initialize(
      name:,
      requirement:,
      platform:,
      original_requirement: nil,
      type: nil,
      direct: nil,
      deprecated: nil,
      local: nil,
      optional: nil,
      original_name: nil,
      source: nil
    )
      @name = name
      @platform = platform
      @requirement = requirement || "*"
      @original_requirement = original_requirement
      @type = type
      @direct = direct
      @deprecated = deprecated
      @local = local
      @optional = optional
      @original_name = original_name
      @source = source
    end

    def eql?(other)
      FIELDS.all? { |f| public_send(f) == other.public_send(f) }
    end
    alias == eql?

    def [](key)
      public_send(key)
    end

    def to_h
      FIELDS.to_h { |f| [f, public_send(f)] }
    end

    def hash
      FIELDS.map { |f| public_send(f) }.hash
    end
  end
end
