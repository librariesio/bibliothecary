require 'deb_control'

module Bibliothecary
  module Parsers
    class CRAN
      PLATFORM_NAME = 'cran'
      REQUIRE_REGEXP = /([a-zA-Z0-9\-_\.]+)\s?\(?([><=\s\d\.,]+)?\)?/

      def self.parse(filename, file_contents)
        if filename.match(/^DESCRIPTION$/i)
          control = DebControl::ControlFileBase.parse(file_contents)
          parse_description(control)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_description(folder_path, file_list)]
      end

      def self.analyse_description(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^DESCRIPTION$/i) }
        return unless path

        manifest = DebControl::ControlFileBase.parse File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_description(manifest)
        }
      rescue
        []
      end

      def self.parse_description(manifest)
        parse_section(manifest, 'Depends') +
        parse_section(manifest, 'Imports') +
        parse_section(manifest, 'Suggests') +
        parse_section(manifest, 'Enhances')
      end

      def self.parse_section(manifest, name)
        deps = manifest.first[name].gsub("\n", '').split(',').map(&:strip)
        deps.map do |dependency|
          dep = dependency.match(REQUIRE_REGEXP)
          {
            name: dep[1],
            version: dep[2] || '*',
            type: name.downcase
          }
        end
      end
    end
  end
end
