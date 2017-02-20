module Bibliothecary
  module Analyser
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def parse_file(filename, contents)
        mapping.each do |regex, method_name|
          if filename.match(regex)
            return send(method_name, contents)
          end
        end
        return []
      end

      def match?(filename)
        mapping.keys.any?{|regex| filename.match(regex) }
      end

      def platform_name
        self.name.to_s.split('::').last.downcase
      end

      def analyse(folder_path, file_list)
        file_list.map do |path|
          filename = path.gsub(folder_path, '').gsub(/^\//, '')
          contents = File.open(path).read
          analyse_contents(filename, contents)
        end.compact
      end

      def analyse_contents(filename, contents)
        begin
          dependencies = parse_file(filename, contents)
          if dependencies.any?
            {
              platform: platform_name,
              path: filename,
              dependencies: dependencies
            }
          else
            nil
          end
        rescue
          nil
        end
      end

      def parse_ruby_manifest(manifest)
        manifest.dependencies.inject([]) do |deps, dep|
          deps.push({
            name: dep.name,
            requirement: dep.requirement.to_s,
            type: dep.type
          })
        end.uniq
      end
    end
  end
end
