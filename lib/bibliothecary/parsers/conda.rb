require 'json'

module Bibliothecary
  module Parsers
    class Conda
      include Bibliothecary::Analyser
      FILE_KINDS = %w[manifest lockfile]

      def self.mapping
        {
          match_filename("environment.yml") => {
            parser: :parse_conda_environment,
            kind: FILE_KINDS
          },
          match_filename("environment.yaml") => {
            parser: :parse_conda_environment,
            kind: FILE_KINDS
          }
        }
      end

      def self.parse_conda_environment(file_contents)
        manifest = call_conda_parser_web(file_contents)

        Hash[FILE_KINDS.collect { |kind| [kind, map_dependencies(manifest, kind, "runtime")] }]
      end

      def self.call_conda_parser_web(file_contents)
        host = Bibliothecary.configuration.conda_parser_host
        response = Typhoeus.post(
          "#{host}/parse",
          headers: {
              ContentType: 'multipart/form-data'
          },
          # TODO: Can we ever get the filename from the method call from `match_filename` in the future? would be nice to be able to.
          body: {file: file_contents, filename: 'environment.yml'}
        )
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{host}/parse", response.response_code) unless response.success?

        JSON.parse(response.body)
      end

      # Overrides Analyser.analyse_contents_from_info
      def self.analyse_contents_from_info(info)
        dependencies = parse_conda_environment(info.contents)

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
    end
  end
end
