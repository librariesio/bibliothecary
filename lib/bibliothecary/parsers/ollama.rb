require 'modelfile_parser'

module Bibliothecary
  module Parsers
    class Ollama
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("Modelfile") => {
            kind: 'manifest',
            parser: :parse_modelfile,
            related_to: [ 'manifest' ]
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_modelfile(file_contents, options: {})
        source = options.fetch(:filename, 'Modelfile')
        deps = ModelfileParser.new(file_contents).parse.map do |dep|
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: dep[:name],
            requirement: dep[:requirement],
            type: dep[:type],
            source: source
          )
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
