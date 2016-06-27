require 'sdl4r'

class SdlParser
  attr_reader :contents, :type
  def initialize(type, contents)
    @contents = contents
    @type = type || 'runtime'
  end

  def to_json
    Oj.dump(dependencies, mode: :compat) unless contents.nil?
  end

  def dependencies
    parse.children('dependency').inject([]) do |deps, dep|
      deps.push({
        name: dep.value,
        version: dep.attribute('version') || ">= 0",
        type: type,
      })
    end.uniq
  end

  def parse
    SDL4R::read(contents)
  end
end
