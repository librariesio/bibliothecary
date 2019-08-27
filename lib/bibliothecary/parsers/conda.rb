require 'json'

module Bibliothecary
  module Parsers
    class Conda
      include Bibliothecary::Analyser
      FILE_KINDS = %w[manifest lockfile]

      def self.mapping
        # Map Conda to environment.yml or environment.yaml, this may not be all that people use, 
        # so TODO:determine if there is a need to parse other filenames
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
          # TODO: Can we ever get the filename from the method call from `match_filename` in the future?
          # Would be nice to be able to send the file name that clients use for their environment to be able to log better.
          body: {file: file_contents, filename: 'environment.yml'}
        )
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{host}/parse", response.response_code) unless response.success?

        results = JSON.parse(response.body)
        Hash[FILE_KINDS.collect { |kind| [kind, map_dependencies(results, kind, "runtime")] }]
      end
    end
  end
end
