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
        analyses = file_list.map do |path|
          filename = path.gsub(folder_path, '').gsub(/^\//, '')
          next unless match?(filename)
          contents = File.open(path).read
          analyse_contents(filename, contents)
        end.compact

        analyses.each do |analysis|
          analysis[:related_paths] = []
        end

        # associate manifests and lockfiles in the same directory;
        # note that right now we're in the context of a single
        # package manager, so manifest and lockfile in the
        # same directory is considered proof that they are
        # matched.
        by_dirname = {}
        analyses.each do |analysis|
          dirname = File.dirname(analysis[:path])
          by_dirname[dirname] ||= []
          by_dirname[dirname].push(analysis)
        end

        # set related_paths so manifests point to lockfiles and vice versa
        by_dirname.each do |_, all_for_dirname|
          manifest = all_for_dirname.find { |analysis| analysis[:kind] == "manifest" }
          lockfiles = all_for_dirname.select { |analysis| analysis[:kind] == "lockfile" }
          manifest[:related_paths] = lockfiles.map { |analysis| analysis[:path] }
          lockfiles.each do |analysis|
            analysis[:related_paths].push(manifest[:path])
          end
        end

        analyses
      end

      def analyse_contents(filename, contents)
        dependencies = parse_file(filename, contents)
        if dependencies && dependencies.any?
          {
            platform: platform_name,
            path: filename,
            dependencies: dependencies,
            kind: determine_kind(filename)
          }
        end
      # rescue
      #   nil
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
