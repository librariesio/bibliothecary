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
        [parse_conda(info), parse_pip(info)].flatten.compact
      rescue Bibliothecary::RemoteParsingError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, "runtime", e.message)
      rescue Psych::SyntaxError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, "runtime", e.message)
      end

      private

      def self.parse_conda(info)
        results = call_conda_parser_web(info.contents)
        FILE_KINDS.map do |kind|
          Bibliothecary::Analyser.create_analysis(
            "conda",
            info.relative_path,
            kind,
            results[kind.to_sym].map { |dep| dep.slice(:name, :requirement).merge(:type => "runtime") }
          )
        end
      end

      def self.parse_pip(info)
        dependencies = YAML.safe_load(info.contents)["dependencies"]
        pip = dependencies.find { |dep| dep.is_a?(Hash) && dep["pip"]}
        return unless pip

        Bibliothecary::Analyser.create_analysis(
          "pypi",
          info.relative_path,
          "manifest",
          Pypi.parse_requirements_txt(pip["pip"].join("\n"))
        )
      end

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

        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
