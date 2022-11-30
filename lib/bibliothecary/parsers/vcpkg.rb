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
        json = JSON.parse(file_contents)
        json["dependencies"].map do |dependency|
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
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end.uniq
      end
    end
  end
end
