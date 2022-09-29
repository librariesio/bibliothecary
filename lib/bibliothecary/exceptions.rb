module Bibliothecary
  class RemoteParsingError < StandardError
    attr_accessor :code
    def initialize(msg, code)
      @code = code
      super(msg)
    end
  end

  class FileParsingError < StandardError
    attr_accessor :filename
    def initialize(msg, filename)
      @filename = filename
      msg = "#{filename}: #{msg}" unless msg.include?(filename)
      super("#{msg}")
    end
  end

  class InvalidPackageName < StandardError
    def initialize(msg)
      super(msg)
    end
  end
end
