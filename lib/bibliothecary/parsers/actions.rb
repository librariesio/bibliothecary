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
        yaml = YAML.load(file_contents)
        case yaml['runs']['using']
        when /^node/
          [{
            type: 'javascript',
            name: yaml['runs']['main'],
            requirement: yaml['runs']['using'],
          }]
        when 'docker'
          [
            parse_requirement(yaml['runs']['image'],'docker')
          ]
        when 'composite'
          yaml['runs']['steps'].map { |step| 
            parse_requirement(step['uses'],'composite')
          }.compact
        else
          []
        end
      end

      def self.parse_workflow(file_contents, options: {})
        yaml = YAML.load(file_contents)

        uses_strings = deep_fetch_uses(yaml).uniq
        uses_strings.map do |use| 
          parse_requirement(use,'composite')
        end + parse_jobs(yaml)

      end

      def self.parse_jobs(yaml)
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
          {
            type: 'docker',
            name: name,
            requirement: version || '*',
          }
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

      def self.parse_requirement(requirement,type)
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
        {
          type: type,
          name: name,
          requirement: version || '*',
        }
      end
    end
  end
end
