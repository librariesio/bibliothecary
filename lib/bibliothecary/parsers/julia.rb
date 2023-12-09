module Bibliothecary
  module Parsers
    class Julia
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("REQUIRE", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_require,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_require(file_contents, options: {})
        deps = []
        file_contents.split("\n").each do |line|
          next if line.match(/^#/) || line.empty?
          split = line.split(/\s/)
          if line.match(/^@/)
            name = split[1]
            reqs = split[2, split.length].join(" ")
          else
            name = split[0]
            reqs = split[1, split.length].join(" ")
          end
          reqs = "*" if reqs.empty?
          next if name.empty?

          deps << {
            name: name,
            requirement: reqs,
            type: "runtime",
          }
        end
        deps
      end
    end
  end
end
