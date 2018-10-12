module Bibliothecary
  module Analyser
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def mapping_entry_match?(regex, details, filename, contents)
        if filename.match(regex)
          # we only want to load contents if we don't have them already
          # and there's a content_matcher method to use
          return true if details[:content_matcher].nil?
          # this is the libraries.io case where we won't load all .xml
          # files (for example) just to look at their contents, we'll
          # assume they are not manifests.
          return false if contents.nil?
          return send(details[:content_matcher], contents)
        else
          return false
        end
      end

      def parse_file(filename, contents)
        mapping.each do |regex, details|
          if mapping_entry_match?(regex, details, filename, contents)
            begin
              return send(details[:parser], contents)
            rescue Exception => e # default is StandardError but C bindings throw Exceptions
              # the C xml parser also puts a newline at the end of the message
              raise Bibliothecary::FileParsingError.new(e.message.strip, filename)
            end
          end
        end
        # this can be raised if we don't check match_info?, or we check match? but
        # did not have the file contents so it turns out for example that a
        # .xml file isn't a manifest after all.
        raise Bibliothecary::FileParsingError.new("No parser for this file type", filename)
      end

      # this is broken with contents=nil because it can't look at file
      # contents, so skips manifests that are ambiguously a
      # manifest considering only the filename. However, those are
      # the semantics that libraries.io uses since it doesn't have
      # the files locally.
      def match?(filename, contents = nil)
        mapping.any? do |regex, details|
          mapping_entry_match?(regex, details, filename, contents)
        end
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

        analyses.each do |analysis|
          dirname = File.dirname(analysis[:path])
          by_dirname[analysis[:kind]][dirname].push(analysis)
        end

        by_dirname["manifest"].each do |_, manifests|
          manifests.delete_if { |manifest| !determine_can_have_lockfile(manifest[:path]) }
        end

        set_related_paths_field(by_dirname["manifest"], by_dirname["lockfile"])
        set_related_paths_field(by_dirname["lockfile"], by_dirname["manifest"])
      end

      def analyse(folder_path, file_list)
        analyse_file_info(file_list.map { |absolute_path| FileInfo.new(folder_path, absolute_path) })
      end

      def analyse_file_info(file_info_list)
        analyses = file_info_list.map do |info|
          next unless match?(info.relative_path, info.contents)
          analyse_contents(info.relative_path, info.contents)
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
            kind: determine_kind(filename, contents),
            success: true
          }
        end
      rescue Bibliothecary::FileParsingError => e
        {
          platform: platform_name,
          path: filename,
          dependencies: nil,
          kind: determine_kind(filename, contents),
          success: false,
          error_message: e.message
        }
      end

      # calling this with contents=nil is broken, but kept for back compat
      def determine_kind(filename, contents = nil)
        mapping.each do |regex, details|
          if mapping_entry_match?(regex, details, filename, contents)
            return details[:kind]
          end
        end
        return nil
      end

      # calling this with contents=nil is broken, but kept for back compat
      def determine_can_have_lockfile(filename, contents = nil)
        mapping.each do |regex, details|
          if mapping_entry_match?(regex, details, filename, contents)
            return details.fetch(:can_have_lockfile, true)
          end
        end
        return true
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
