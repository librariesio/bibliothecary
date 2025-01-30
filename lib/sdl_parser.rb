# frozen_string_literal: true

require "sdl4r"

class SdlParser
  attr_reader :contents, :type

  def initialize(type, contents, source = nil)
    @contents = contents
    @type = type || "runtime"
    @source = source
  end

  def dependencies
    parse.children("dependency").inject([]) do |deps, dep|
      deps.push(Bibliothecary::Dependency.new(
                  name: dep.value,
                  requirement: dep.attribute("version") || ">= 0",
                  type: type,
                  source: @source
                ))
    end.uniq
  end

  def parse
    SDL4R.read(contents)
  end
end
