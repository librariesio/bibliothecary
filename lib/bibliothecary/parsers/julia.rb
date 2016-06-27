# REQUIRE
module Bibliothecary
  module Parsers
    class Julia
      PLATFORM_NAME = 'julia'

      def self.parse(filename, file_contents)
        if filename.match(/^REQUIRE$/i)
          parse_require(file_contents)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_json(folder_path, file_list)]
      end

      def self.analyse_json(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^REQUIRE$/i) }
        return unless path

        manifest = File.open(path).read

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: parse_require(manifest)
        }
      end

      def self.parse_require(manifest)
        manifest.split("\n").map do |line|
          match = line.split(/\s/)
          {
            name: match[0],
            requirement: match[1] || '*',
            type: 'runtime'
          }
        end
      end
    end
  end
end
