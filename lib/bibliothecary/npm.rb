require 'json'

module Bibliothecary
  class NPM
    def self.analyse(file_list)
      path = file_list.find{|path| path.match(/^package\.json$/) }
      return unless path

      manifest = JSON.parse File.open(path).read

      {
        platform: 'npm',
        path: path,
        dependencies: parse_manifest(manifest)
      }
    end

    def self.parse_manifest(manifest)
      manifest.fetch('dependencies',[]).map do |name, requirement|
        {
          name: name,
          requirement: requirement,
          type: 'runtime'
        }
      end + manifest.fetch('devDependencies',[]).map do |name, requirement|
        {
          name: name,
          requirement: requirement,
          type: 'development'
        }
      end
    end
  end
end
