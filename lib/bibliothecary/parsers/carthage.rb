require 'cartfile_parser'

module Bibliothecary
  module Parsers
    class Carthage
      PLATFORM_NAME = 'Carthage'

      def self.parse(filename, file_contents)
        if filename.match(/^Cartfile$/)
          manifest = CartfileParser.new(:runtime, file_contents).dependencies
        elsif filename.match(/^Cartfile\.private$/)
          manifest = CartfileParser.new(:runtime, file_contents).dependencies
        elsif filename.match(/^Cartfile\.resolved$/)
          manifest = CartfileParser.new(:runtime, file_contents).dependencies
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [
          analyse_cartfile(folder_path, file_list),
          analyse_cartfile_private(folder_path, file_list),
          analyse_cartfile_resolved(folder_path, file_list)
        ]
      end

      def self.analyse_cartfile(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cartfile$/) }
        return unless path

        manifest = CartfileParser.new(:runtime, File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: manifest.dependencies
        }
      end

      def self.analyse_cartfile_private(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cartfile\.private$/) }
        return unless path

        manifest = CartfileParser.new(:runtime, File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: manifest.dependencies
        }
      end

      def self.analyse_cartfile_resolved(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cartfile\.resolved$/) }
        return unless path

        manifest = CartfileParser.new(:runtime, File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: manifest.dependencies
        }
      end

    end
  end
end
