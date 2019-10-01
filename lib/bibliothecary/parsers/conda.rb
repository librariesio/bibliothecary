require "json"

module Bibliothecary
  module Parsers
    class Conda
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("environment.yml") => {
            parser: :parse_conda,
            kind: "manifest",
          },
          match_filename("environment.yaml") => {
            parser: :parse_conda,
            kind: "manifest",
          },
          match_filename("environment.yml.lock") => {
            parser: :parse_conda_lockfile,
            kind: "lockfile",
          },
          match_filename("environment.yaml.lock") => {
            parser: :parse_conda_lockfile,
            kind: "lockfile",
          },
        }
      end

      def self.parse_conda(info)
        dependencies = call_conda_parser_web(info, :manifest)[:manifest]
        dependencies.map { |dep| dep.merge(type: "runtime") }
      end

      def self.parse_conda_lockfile(info)
        dependencies = call_conda_parser_web(info, :lockfile)[:lockfile]
        dependencies.map { |dep| dep.merge(type: "runtime") }
      end

      private_class_method def self.call_conda_parser_web(file_contents, kind)
        host = Bibliothecary.configuration.conda_parser_host
        response = Typhoeus.post(
          "#{host}/parse",
          headers: {
            ContentType: "multipart/form-data",
          },
          body: {
            file: file_contents,
            # Sending the filename with .lock if this is a lockfile, request, and just .yml if it is a manifest.
            # This allows us to not have to create a .lock file anywhere, except in this post as the filename parameter
            filename: kind == "manifest" ? "environment.yml" : "environment.yml.lock",
          }
        )
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{host}/parse", response.response_code) unless response.success?

        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
