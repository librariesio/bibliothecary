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

      def set_related_paths_field(by_dirname_dest, by_dirname_source)
        by_dirname_dest.each do |dirname, analyses|
          analyses.each do |analysis|
            source_analyses = by_dirname_source[dirname].map { |source_analysis| source_analysis[:path] }
            analysis[:related_paths] = source_analyses.sort
          end
        end
      end

      def add_related_paths(analyses)
        analyses.each do |analysis|
          analysis[:related_paths] = []
        end

        # associate manifests and lockfiles in the same directory;

        # note that right now we're in the context of a single
        # package manager, so manifest and lockfile in the
        # same directory is considered proof that they are
        # matched.

        by_dirname = {
          "manifest" => Hash.new { |h, k| h[k] = [] },
          "lockfile" => Hash.new { |h, k| h[k] = [] }
        }
        by_dirname_manifests = by_dirname["manifest"]
        by_dirname_lockfiles = by_dirname["lockfile"]

        analyses.each do |analysis|
          dirname = File.dirname(analysis[:path])
          by_dirname[analysis[:kind]][dirname].push(analysis)
        end

        set_related_paths_field(by_dirname_lockfiles, by_dirname_manifests)
        set_related_paths_field(by_dirname_manifests, by_dirname_lockfiles)
      end

      def analyse(folder_path, file_list)
        analyses = file_list.map do |path|
          filename = path.gsub(folder_path, '').gsub(/^\//, '')
          next unless match?(filename)
          contents = File.open(path).read
          analyse_contents(filename, contents)
        end.compact

        add_related_paths(analyses)

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
