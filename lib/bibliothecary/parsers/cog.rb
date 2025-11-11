require 'yaml'

module Bibliothecary
  module Parsers
    class Cog
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("cog.yaml") => {
            kind: 'manifest',
            parser: :parse_cog_yaml,
            related_to: [ 'manifest' ]
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_cog_yaml(file_contents, options: {})
        source = options.fetch(:filename, 'cog.yaml')
        manifest = YAML.load(file_contents)

        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest.is_a?(Hash)
        return Bibliothecary::ParserResult.new(dependencies: []) unless manifest['build']

        deps = []
        build = manifest['build']

        # Parse python_packages (list format: "package==version")
        if build['python_packages']
          build['python_packages'].each do |pkg|
            next unless pkg.is_a?(String)

            # Split package==version or package>=version etc.
            if pkg =~ /^([a-zA-Z0-9\-_.]+)(==|>=|<=|>|<|~=)(.+)$/
              name = $1
              requirement = $3
            else
              name = pkg
              requirement = '*'
            end

            deps << Bibliothecary::Dependency.new(
              platform: platform_name,
              name: name,
              requirement: requirement,
              type: 'runtime',
              source: source
            )
          end
        end

        # Note: python_requirements points to a separate requirements.txt file
        # which would be parsed by the PyPI parser, so we don't duplicate that here

        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
