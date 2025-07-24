# frozen_string_literal: true

module Bibliothecary
  # ParserResult bundles together a list of dependencies and the project name.
  #
  # @attr_reader [Array<Dependency>] dependencies The list of Dependency objects
  # @attr_reader [String,nil] project_name The name of the project
  class ParserResult
    FIELDS = %i[
      dependencies
      project_name
    ].freeze

    attr_reader(*FIELDS)

    def initialize(
      dependencies:,
      project_name: nil
    )
      @dependencies = dependencies
      @project_name = project_name
    end

    def eql?(other)
      FIELDS.all? { |f| public_send(f) == other.public_send(f) }
    end
    alias == eql?

    def to_h
      FIELDS.to_h { |f| [f, public_send(f)] }
    end

    def hash
      FIELDS.map { |f| public_send(f) }.hash
    end
  end
end
