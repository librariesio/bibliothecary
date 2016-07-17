module Bibliothecary
  module Analyser
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def platform_name
        self.name.to_s.split('::').last.downcase
      end

      def analyse(folder_path, file_list)
        file_list.map do |path|
          file_contents = File.open(path).read
          filename = path.gsub(folder_path, '').gsub(/^\//, '')
          analyse_file(filename, file_contents, path)
        end.compact
      end

      def analyse_file(filename, file_contents, path)
        begin
          dependencies = parse(filename, file_contents)
          if dependencies.any?
            {
              platform: platform_name,
              path: path,
              dependencies: dependencies
            }
          else
            nil
          end
        rescue
          nil
        end
      end
    end
  end
end
