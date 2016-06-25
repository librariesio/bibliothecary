require 'rogdl'

class CartfileParser
  attr_reader :contents, :type
  def initialize(type, contents)
    @contents = contents
    @type = type || 'runtime'
  end

  def to_json
    Oj.dump(dependencies, mode: :compat) unless contents.nil?
  end

  def dependencies
    parse.inject([]) do |deps, dep|
      deps.push({
        name: dep[1],
        version: [dep[2],dep[3]].join(' ') || ">= 0",
        type: type,
      })
    end.uniq
  end

  def parse
    parser = Rogdl::Parser.new
    parser.translate(contents)
    parser.lines.reject { |line| line.empty? }
  end
end
