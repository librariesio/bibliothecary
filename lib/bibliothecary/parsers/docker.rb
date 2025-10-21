require 'yaml'
require 'dockerfile_parser'

module Bibliothecary
  module Parsers
    class Docker
      include Bibliothecary::Analyser

      DOCKER_COMPOSE_REGEXP = /docker-compose[a-zA-Z0-9\-_\.]*\.yml$/

      def self.mapping
        {
          lambda { |p| DOCKER_COMPOSE_REGEXP.match(p) } => {
            kind: 'manifest',
            parser: :parse_docker_compose,
            related_to: [ 'manifest' ]
          },
          match_filename("Dockerfile") => {
            kind: 'manifest',
            parser: :parse_dockerfile,
            related_to: [ 'manifest' ]
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_docker_compose(file_contents, options: {})
        source = options.fetch(:filename, 'docker-compose.yml')
        manifest = YAML.load file_contents
        deps = manifest['services'].map do |k, v|
          next if v['image'].nil?
          image = v['image'].split(':')
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: image[0],
            requirement: image[1] || 'latest',
            type: 'runtime',
            source: source
          )
        end.compact
        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      def self.parse_dockerfile(file_contents, options: {})
        source = options.fetch(:filename, 'Dockerfile')
        deps = DockerfileParser.new(file_contents).parse.map do |dep|
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
