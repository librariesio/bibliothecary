module Bibliothecary
  module Parsers
    class Julia
      include Bibliothecary::Analyser

      def self.mapping
        {
          /^REQUIRE$/i => :parse_require
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
