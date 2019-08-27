require 'json'

module Bibliothecary
  module Parsers
    class Conda
      include Bibliothecary::Analyser
      FILE_KINDS = %w[manifest lockfile]

      def self.mapping
        {
          match_filename("environment.yml") => {
            kind: FILE_KINDS
          },
          match_filename("environment.yaml") => {
            kind: FILE_KINDS
          }
        }
      end

      # Overrides Analyser.analyse_contents_from_info
      def self.analyse_contents_from_info(info)
        dependencies = call_conda_parser_web(info.contents)

        FILE_KINDS.map do |kind|
          Bibliothecary::Analyser.create_analysis(
            "conda",
            info.relative_path,
            kind,
            dependencies[kind]
          )
        end
      rescue Bibliothecary::RemoteParsingError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, "runtime", e.message)
      end
    
      private

      def self.call_conda_parser_web(file_contents)
        host = Bibliothecary.configuration.conda_parser_host
        response = Typhoeus.post(
          "#{host}/parse",
          headers: {
              ContentType: 'multipart/form-data'
          },
          # hardcoding `environment.yml` to send to `conda.libraries.io`, downside is logs will always show `environment.yml` there
          body: {file: file_contents, filename: 'environment.yml'} 
        )
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{host}/parse", response.response_code) unless response.success?

        results = JSON.parse(response.body)
        Hash[FILE_KINDS.collect { |kind| [kind, map_dependencies(results, kind, "runtime")] }]
      end
    end
  end
end
