require 'yaml'

module Bibliothecary
  module Parsers
    class MLflow
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("MLmodel") => {
            kind: 'manifest',
            parser: :parse_mlmodel,
            related_to: [ 'manifest' ]
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_mlmodel(file_contents, options: {})
        source = options.fetch(:filename, 'MLmodel')
        manifest = YAML.load(file_contents)

        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest.is_a?(Hash)
        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest['flavors']

        deps = []

        # Check each flavor for model references
        manifest['flavors'].each do |flavor_name, flavor_config|
          next unless flavor_config.is_a?(Hash)

          # HuggingFace transformers flavor with source_model_name
          if flavor_config['source_model_name']
            deps << Bibliothecary::Dependency.new(
              platform: platform_name,
              name: flavor_config['source_model_name'],
              requirement: flavor_config['source_model_revision'] || 'latest',
              type: 'runtime',
              source: source
            )
          end

          # Other potential model reference patterns
          # Could be extended to handle other flavors with model references
        end

        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
