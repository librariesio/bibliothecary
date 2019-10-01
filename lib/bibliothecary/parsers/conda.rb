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
            # Unfortunately we do not get the filename in the mapping parsers, so hardcoding the file name depending on the kind
            filename: kind == "manifest" ? "environment.yml" : "environment.yml.lock",
          }
        )
        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{host}/parse", response.response_code) unless response.success?

        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
