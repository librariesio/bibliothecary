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
        manifest = YAML.load file_contents
        manifest['services'].map do |k, v|
          next if v['image'].nil?
          image = v['image'].split(':')
          {
            name: image[0],
            requirement: image[1] || 'latest',
            type: 'runtime'
          }
        end.compact
      end

      def self.parse_dockerfile(file_contents, options: {})
        DockerfileParser.new(file_contents).parse
      end
    end
  end
end
