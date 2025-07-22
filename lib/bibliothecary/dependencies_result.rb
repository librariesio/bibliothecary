# frozen_string_literal: true

module Bibliothecary
  # DependenciesResult bundles together a list of dependencies and the project name.
  #
  # @attr_reader [Array<Dependency>] dependencies The list of Dependency objects
  # @attr_reader [String,nil] project_name The name of the project
  # @attr_reader [String,nil] project_name The version of the project
  class DependenciesResult
    FIELDS = %i[
      dependencies
      project_name
      project_version
    ].freeze

    attr_reader(*FIELDS)

    def initialize(
      dependencies: [],
      project_name: nil,
      project_version: nil
    )
      @dependencies = dependencies
      @project_name = project_name
      @project_version = project_version
    end

    def eql?(other)
      FIELDS.all? { |f| public_send(f) == other.public_send(f) }
    end
    alias == eql?

    def hash
      FIELDS.map { |f| public_send(f) }.hash
    end
  end
end
