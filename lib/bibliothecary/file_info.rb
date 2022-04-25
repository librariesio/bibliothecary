require 'pathname'

module Bibliothecary
  # A representation of a file on the filesystem, with location information
  # and package manager information if needed.
  class FileInfo
    attr_reader :folder_path
    attr_reader :relative_path
    attr_reader :full_path
    attr_accessor :package_manager

    def contents
      @contents ||=
        begin
          if @folder_path.nil?
            # if we have no folder_path then we aren't dealing with a
            # file that's actually on the filesystem
            nil
          else
            File.open(@full_path).read
          end
        end
    end

    # If the FileInfo represents an actual file on disk,
    # the contents can be nil and lazy-loaded; we allow
    # contents to be passed in here to allow pulling them
    # from somewhere other than the disk.
    def initialize(folder_path, full_path, contents = nil)
      # Note that cleanpath does NOT touch the filesystem,
      # leaving the lazy-load of file contents as the only
      # time we touch the filesystem.

      full_pathname = Pathname.new(full_path)
      @full_path = full_pathname.cleanpath.to_path

      if folder_path.nil?
        # this is the case where we e.g. have filenames from the GitHub API
        # and don't have a local folder
        @folder_path = nil
        @relative_path = @full_path
      else
        folder_pathname = Pathname.new(folder_path)
        @folder_path = folder_pathname.cleanpath.to_path
        @relative_path = full_pathname.relative_path_from(folder_pathname).cleanpath.to_path
      end

      @contents = contents

      @package_manager = nil
    end
  end
end
