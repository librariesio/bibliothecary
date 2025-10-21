# frozen_string_literal: true

require "yaml"

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
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_conda(file_contents, options: {})
        manifest = YAML.load(file_contents)
        deps = manifest["dependencies"]
        dependencies = deps.map do |dep|
          next unless dep.is_a? String # only deal with strings to skip parsing pip stuff

          parsed = parse_name_requirement_from_matchspec(dep)
          Dependency.new(
            **parsed,
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end.compact
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_name_requirement_from_matchspec(matchspec)
        # simplified version of the implementation in conda to handle what we care about
        # https://github.com/conda/conda/blob/main/conda/models/match_spec.py#L598
        # (channel(/subdir):(namespace):)name(version(build))[key1=value1,key2=value2]
        return if matchspec.end_with?("@")

        # strip off comments and optional features
        matchspec = matchspec.split("#", 2).first
        matchspec = matchspec.split(" if ", 2).first

        # strip off brackets
        matchspec = matchspec.match(/^(.*)(?:\[(.*)\])?$/)[1]

        # strip off any parens
        matchspec = matchspec.match(/^(.*)(?:(\(.*\)))?$/)[1]

        # deal with channel and namespace, I wish there was rsplit in ruby
        split = matchspec.reverse.split(":", 2)
        matchspec = split.last.reverse

        # split the name from the version/build combo
        matches = matchspec.match(/([^ =<>!~]+)?([><!=~ ].+)?/)
        name = matches[1]
        version_build = matches[2]

        version = nil
        if matches && matches[2]
          version_build = matches[2]
          # and now deal with getting the version from version/build
          matches = version_build.match(/((?:.+?)[^><!,|]?)(?:(?<![=!|,<>~])(?:[ =])([^-=,|<>~]+?))?$/)
          version = if matches
                      matches[1].strip
                    else
                      version_build.strip
                    end
        end
        # if it's an exact requirement, lose the =
        if version&.start_with?("==")
          version = version[2..]
        elsif version&.start_with?("=")
          version = version[1..]
        end

        {
          name: name,
          requirement: version || "", # NOTE: this ignores build info
        }
      end
    end
  end
end
