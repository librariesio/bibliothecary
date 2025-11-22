# frozen_string_literal: true

module Bibliothecary
  module ParserMixins
    # Provide JSON Runtime Manifest parsing
    module JSONRuntime
      def parse_json_runtime_manifest(file_contents, options: {})
        dependencies = JSON.parse(file_contents).fetch("dependencies", []).map do |name, requirement|
          Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: "runtime",
            source: options.fetch(:filename, nil)
          )
        end

        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end