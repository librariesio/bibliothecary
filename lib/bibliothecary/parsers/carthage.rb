module Bibliothecary
  module Parsers
    class Carthage
      PLATFORM_NAME = 'Carthage'

      def self.parse(filename, file_contents)
        if filename.match(/^Cartfile$/)
          parse_cartfile(file_contents)
        elsif filename.match(/^Cartfile\.private$/)
          parse_cartfile_private(file_contents)
        elsif filename.match(/^Cartfile\.resolved$/)
          parse_cartfile_resolved(file_contents)
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

        manifest = parse_cartfile(File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: manifest.dependencies
        }
      rescue
        []
      end

      def self.analyse_cartfile_private(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cartfile\.private$/) }
        return unless path

        manifest = parse_cartfile_private(File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: manifest.dependencies
        }
      rescue
        []
      end

      def self.analyse_cartfile_resolved(folder_path, file_list)
        path = file_list.find{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/^Cartfile\.resolved$/) }
        return unless path

        manifest = parse_cartfile_resolved(File.open(path).read)

        {
          platform: PLATFORM_NAME,
          path: path,
          dependencies: manifest.dependencies
        }
      rescue
        []
      end

      def self.parse_cartfile(manifest)
        response = Typhoeus.post("https://carthageparser.herokuapp.com/cartfile", params: {body: manifest})
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            version: dependency['version'],
            type: dependency["type"]
          }
        end
      end

      def self.parse_cartfile_private(manifest)
        response = Typhoeus.post("https://carthageparser.herokuapp.com/cartfile.private", params: {body: manifest})
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            version: dependency['version'],
            type: dependency["type"]
          }
        end
      end

      def self.parse_cartfile_resolved(manifest)
        response = Typhoeus.post("https://carthageparser.herokuapp.com/cartfile.resolved", params: {body: manifest})
        json = JSON.parse(response.body)

        json.map do |dependency|
          {
            name: dependency['name'],
            version: dependency['version'],
            type: dependency["type"]
          }
        end
      end
    end
  end
end
