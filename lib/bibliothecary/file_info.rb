require 'pathname'

module Bibliothecary
  class FileInfo
    def folder_path
      @folder_pathname.to_path
    end

    def absolute_path
      @absolute_pathname.to_path
    end

    def relative_path
      @relative_pathname.to_path
    end

    def contents
      @contents ||= @absolute_pathname.open.read
    end

    # If the FileInfo represents an actual file on disk,
    # the contents can be nil and lazy-loaded; we allow
    # contents to be passed in here to allow pulling them
    # from somewhere other than the disk.
    def initialize(folder_path, absolute_path, contents = nil)
      # Note that cleanpath does NOT touch the filesystem,
      # leaving the lazy-load of file contents as the only
      # time we touch the filesystem.
      @folder_pathname = Pathname.new(folder_path).cleanpath
      @absolute_pathname = Pathname.new(absolute_path).cleanpath
      @relative_pathname = @absolute_pathname.relative_path_from(@folder_pathname)
      @contents = contents
    end
  end
end
