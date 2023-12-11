module Bibliothecary
  class RemoteParsingError < StandardError
    attr_accessor :code
    def initialize(msg, code)
      @code = code
      super(msg)
    end
  end

  class FileParsingError < StandardError
    attr_accessor :filename, :location
    def initialize(msg, filename, location=nil)
      @filename = filename
      @location = location # source code location of the error, e.g. "lib/hi.rb:34"
      msg = "#{filename}: #{msg}" unless msg.include?(filename)
      super("#{msg}")
    end
  end
end
