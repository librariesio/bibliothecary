module Bibliothecary
  class ParseHostError < StandardError
    attr_accessor :code
    def initialize(msg, code)
      @code = code
      super(msg)
    end
  end
end
