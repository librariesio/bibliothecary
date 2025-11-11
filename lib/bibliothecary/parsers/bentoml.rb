require 'yaml'

module Bibliothecary
  module Parsers
    class BentoML
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("bentofile.yaml") => {
            kind: 'manifest',
            parser: :parse_bentofile,
            related_to: [ 'manifest' ]
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_bentofile(file_contents, options: {})
        source = options.fetch(:filename, 'bentofile.yaml')
        manifest = YAML.load(file_contents)

        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest.is_a?(Hash)
        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest['models']

        deps = manifest['models'].map do |model|
          # Model can be a string like "iris_clf:latest"
          # or a dictionary like { tag: "iris_clf:v1", alias: "my_model" }
          if model.is_a?(String)
            parse_model_string(model, source)
          elsif model.is_a?(Hash) && model['tag']
            parse_model_string(model['tag'], source)
          else
            nil
          end
        end.compact

        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      private

      def self.parse_model_string(model_string, source)
        parts = model_string.split(':')
        Bibliothecary::Dependency.new(
          platform: platform_name,
          name: parts[0],
          requirement: parts[1] || 'latest',
          type: 'runtime',
          source: source
        )
      end
    end
  end
end
