module Bibliothecary
  module MultiParsers
    # Provide JSON Runtime Manifest parsing
    module JSONRuntime
      def parse_json_runtime_manifest(file_contents, options: {}) # rubocop:disable Lint/UnusedMethodArgument
        JSON.parse(file_contents).fetch("dependencies",[]).map do |name, requirement|
          Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
          )
        end
      end
    end
  end
end
