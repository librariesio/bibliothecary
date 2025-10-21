module Bibliothecary
  module Parsers
    class Vcpkg
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("vcpkg.json", case_insensitive: true) => {
            kind: 'manifest',
            parser: :parse_vcpkg_json,
          }
        }
      end

      def self.parse_vcpkg_json(file_contents, options: {})
        source = options.fetch(:filename, 'vcpkg.json')
        json = JSON.parse(file_contents)
        deps = json["dependencies"].map do |dependency|
          name = dependency.is_a?(Hash) ? dependency['name'] : dependency
          if dependency.is_a?(Hash)
            if dependency['version>=']
              requirement = ">=#{dependency['version>=']}"
            else
              requirement = dependency['version'] || dependency['version-semver'] || dependency['version-date'] || dependency['version-string'] || '*'
            end
          else
            requirement = '*'
          end
          Bibliothecary::Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: 'runtime',
            source: source
          )
        end.uniq
        Bibliothecary::ParserResult.new(dependencies: deps)
      end
    end
  end
end
