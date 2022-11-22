require 'yaml'

module Bibliothecary
  module Parsers
    class Actions
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("action.yml") => {
            kind: 'manifest',
            parser: :parse_manifest,
            can_have_lockfile: false
          },
          match_filename("action.yaml") => {
            kind: 'manifest',
            parser: :parse_manifest,
            can_have_lockfile: false
          }
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

      def self.parse_requirement(requirement,type)
        return nil if requirement.nil?
        if requirement =~ /^docker\:\/\//
          docker_name = requirement.split('docker://').last
          name, version = docker_name.split(':')
          name = 'docker://' + name
        elsif requirement =~ /@/
          name,version = requirement.split('@')
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
