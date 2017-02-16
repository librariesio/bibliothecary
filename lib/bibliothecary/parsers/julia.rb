module Bibliothecary
  module Parsers
    class Julia
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^REQUIRE$/i)
          file_contents = File.open(path).read
          parse_require(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^REQUIRE$/i)
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
