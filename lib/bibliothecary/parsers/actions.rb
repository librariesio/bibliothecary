require 'yaml'

module Bibliothecary
  module Parsers
    class Actions
      include Bibliothecary::Analyser

      WORKFLOW_REGEX = /^\.github\/workflows\/.*.y(a)?ml/

      def self.mapping
        {
          match_filenames("action.yml","action.yaml") => {
            kind: 'manifest',
            parser: :parse_manifest,
            can_have_lockfile: false
          },
          lambda { |p| WORKFLOW_REGEX.match(p) } => {
            kind: 'manifest',
            parser: :parse_workflow,
            can_have_lockfile: false
          },
        }
      end

      def self.parse_manifest(file_contents, options: {})
        source = options.fetch(:filename, 'action.yml')
        yaml = YAML.load(file_contents)
        deps = case yaml['runs']['using']
        when /^node/
          [Bibliothecary::Dependency.new(
            platform: platform_name,
            type: 'javascript',
            name: yaml['runs']['main'],
            requirement: yaml['runs']['using'],
            source: source
          )]
        when 'docker'
          [
            parse_requirement(yaml['runs']['image'],'docker', source)
          ]
        when 'composite'
          yaml['runs']['steps'].map { |step|
            parse_requirement(step['uses'],'composite', source)
          }.compact
        else
          []
        end
        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      def self.parse_workflow(file_contents, options: {})
        source = options.fetch(:filename, '.github/workflows/workflow.yml')
        yaml = YAML.load(file_contents)

        uses_strings = deep_fetch_uses(yaml).uniq
        deps = uses_strings.map do |use|
          parse_requirement(use,'composite', source)
        end + parse_jobs(yaml, source)

        Bibliothecary::ParserResult.new(dependencies: deps)
      end

      def self.parse_jobs(yaml, source)
        jobs = yaml.fetch("jobs", [])
        jobs.values.flat_map do |job|
          services = job.fetch("services", [])
          services.map do |name,service|
            case service
            when Hash
              service['image']
            when String
              service
            end
          end
        end.map do |image|
          name,version = image.split(':')
          Bibliothecary::Dependency.new(
            platform: platform_name,
            type: 'docker',
            name: name,
            requirement: version || '*',
            source: source
          )
        end
      end

      def self.deep_fetch_uses(yaml)
        case yaml
        when Hash 
          deep_fetch_uses_from_hash(yaml)
        when Array
          yaml.flat_map do |o|
            deep_fetch_uses(o)
          end
        else
          []
        end
      end

      def self.deep_fetch_uses_from_hash(yaml)
        steps = yaml.fetch("steps", [])

        uses_strings =
          if steps.is_a?(Array) && steps.all?(Hash)
            steps.
              map { |step| step.fetch("uses", nil) }.
              select { |use| use.is_a?(String) }
          else
            []
          end

        uses_strings +
          yaml.values.flat_map { |obj| deep_fetch_uses(obj) }
      end

      def self.parse_requirement(requirement,type, source)
        return nil if requirement.nil?
        if requirement =~ /^docker\:\/\//
          docker_name = requirement.split('docker://').last
          name, version = docker_name.split(':')
          name = 'docker://' + name
          version = version.split('@').first if version =~ /@/
        elsif requirement =~ /@/
          name,version,_sha = requirement.split('@')
        else
          name = requirement
        end
        Bibliothecary::Dependency.new(
          platform: platform_name,
          type: type,
          name: name,
          requirement: version || '*',
          source: source
        )
      end
    end
  end
end
