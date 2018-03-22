module Bibliothecary
  module Analyser
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def parse_file(filename, contents)
        mapping.each do |regex, details|
          if filename.match(regex)
            return send(details[:parser], contents)
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

      def parse_json_runtime_manifest(file_contents)
        JSON.parse(file_contents).fetch('dependencies',[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: 'runtime'
          }
        end
      end

      def map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: type
          }
        end
      end

      def analyse(folder_path, file_list)
        file_list.map do |path|
          filename = path.gsub(folder_path, '').gsub(/^\//, '')
          next unless match?(filename)
          contents = File.open(path).read
          analyse_contents(filename, contents)
        end.compact
      end

      def analyse_contents(filename, contents)
        begin
          dependencies = parse_file(filename, contents)
          if dependencies && dependencies.any?
            {
              platform: platform_name,
              path: filename,
              dependencies: dependencies,
              kind: determine_kind(filename)
            }
          else
            nil
          end
        rescue
          nil
        end
      end

      def determine_kind(filename)
        mapping.each do |regex, details|
          if filename.match(regex)
            return details[:kind]
          end
        end
        return []
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
