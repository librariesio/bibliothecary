require 'yaml'

module Bibliothecary
  module Parsers
    class DVC
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("dvc.yaml") => {
            kind: 'manifest',
            parser: :parse_dvc_yaml,
            related_to: [ 'manifest' ]
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_dvc_yaml(file_contents, options: {})
        source = options.fetch(:filename, 'dvc.yaml')
        manifest = YAML.load(file_contents)

        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest.is_a?(Hash)

        deps = []

        # Parse artifacts section
        if manifest['artifacts']
          manifest['artifacts'].each do |artifact_name, artifact_config|
            next unless artifact_config.is_a?(Hash)
            next unless artifact_config['type'] == 'model'

            # Extract model path as dependency
            if artifact_config['path']
              deps << Bibliothecary::Dependency.new(
                platform: platform_name,
                name: artifact_config['path'],
                requirement: artifact_config.dig('meta', 'version') || 'latest',
                type: 'runtime',
                source: source
              )
            end
          end
        end

        # Parse stages section for model references
        if manifest['stages']
          manifest['stages'].each do |stage_name, stage_config|
            next unless stage_config.is_a?(Hash)

            # Check outputs (outs) for models
            if stage_config['outs']
              stage_config['outs'].each do |out|
                # If output is a model file (by extension or pattern)
                if out.is_a?(String) && (out.match?(/\.(pkl|h5|pt|pth|onnx|joblib|model)$/i) || out.include?('model'))
                  deps << Bibliothecary::Dependency.new(
                    platform: platform_name,
                    name: out,
                    requirement: 'latest',
                    type: 'runtime',
                    source: source
                  )
                end
              end
            end
          end
        end

        Bibliothecary::ParserResult.new(dependencies: deps.uniq { |d| d.name })
      end
    end
  end
end
