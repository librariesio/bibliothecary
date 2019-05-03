module Bibliothecary
  module Analyser
    def self.create_error_analysis(platform_name, relative_path, kind, message)
      {
        platform: platform_name,
        path: relative_path,
        dependencies: nil,
        kind: kind,
        success: false,
        error_message: message
      }
    end

    def self.create_analysis(platform_name, relative_path, kind, dependencies)
      {
        platform: platform_name,
        path: relative_path,
        dependencies: dependencies,
        kind: kind,
        success: true
      }
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def mapping_entry_match?(regex, details, info)
        if info.relative_path.match(regex)
          # we only want to load contents if we don't have them already
          # and there's a content_matcher method to use
          return true if details[:content_matcher].nil?
          # this is the libraries.io case where we won't load all .xml
          # files (for example) just to look at their contents, we'll
          # assume they are not manifests.
          return false if info.contents.nil?
          return send(details[:content_matcher], info.contents)
        else
          return false
        end
      end

      def parse_file(filename, contents)
        mapping.each do |regex, details|
          if mapping_entry_match?(regex, details, FileInfo.new(nil, filename, contents))
            begin
              # The `parser` method should raise an exception if the file is malformed,
              # should return empty [] if the file is fine but simply doesn't contain
              # any dependencies, and should never return nil. At the time of writing
              # this comment, some of the parsers return [] or nil to mean an error
              # which is confusing to users.
              return send(details[:parser], contents)
            rescue Exception => e # default is StandardError but C bindings throw Exceptions
              # the C xml parser also puts a newline at the end of the message
              raise Bibliothecary::FileParsingError.new(e.message.strip, filename)
            end
          end
        end
        # this can be raised if we don't check match?/match_info?,
        # OR don't have the file contents when we check them, so
        # it turns out for example that a .xml file isn't a
        # manifest after all.
        raise Bibliothecary::FileParsingError.new("No parser for this file type", filename)
      end

      # this is broken with contents=nil because it can't look at file
      # contents, so skips manifests that are ambiguously a
      # manifest considering only the filename. However, those are
      # the semantics that libraries.io uses since it doesn't have
      # the files locally.
      def match?(filename, contents = nil)
        match_info?(FileInfo.new(nil, filename, contents))
      end

      def match_info?(info)
        mapping.any? do |regex, details|
          mapping_entry_match?(regex, details, info)
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
          analyses.each do |(_info, analysis)|
            source_analyses = by_dirname_source[dirname].map { |(info, _source_analysis)| info.relative_path }
            analysis[:related_paths] = source_analyses.sort
          end
        end
      end

      def add_related_paths(analyses)
        analyses.each do |(_info, analysis)|
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

        analyses.each do |(info, analysis)|
          dirname = File.dirname(info.relative_path)
          by_dirname[analysis[:kind]][dirname].push([info, analysis])
        end

        by_dirname["manifest"].each do |_, manifests|
          # This determine_can_have_lockfile in theory needs the file contents but
          # in practice doesn't right now since the only mapping that needs
          # file contents is a lockfile and not a manifest so won't reach here.
          manifests.delete_if { |(info, _manifest)| !determine_can_have_lockfile_from_info(info) }
        end

        set_related_paths_field(by_dirname["manifest"], by_dirname["lockfile"])
        set_related_paths_field(by_dirname["lockfile"], by_dirname["manifest"])
      end

      def analyse(folder_path, file_list)
        analyse_file_info(file_list.map { |full_path| FileInfo.new(folder_path, full_path) })
      end

      def analyse_file_info(file_info_list)
        analyses = file_info_list.map do |info|
          next unless match_info?(info)
          [info, analyse_contents_from_info(info)]
        end

        # strip the ones we failed to analyse
        analyses = analyses.reject { |(_info, analysis)| analysis.nil? }

        add_related_paths(analyses)

        analyses.map { |(_info, analysis)| analysis }
      end

      def analyse_contents(filename, contents)
        analyse_contents_from_info(FileInfo.new(nil, filename, contents))
      end

      def analyse_contents_from_info(info)
        kind = determine_kind_from_info(info)
        dependencies = parse_file(info.relative_path, info.contents)

        Bibliothecary::Analyser::create_analysis(platform_name, info.relative_path, kind, dependencies || [])
      rescue Bibliothecary::FileParsingError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, kind, e.message)
      end

      # calling this with contents=nil can produce less-informed
      # results, but kept for back compat
      def determine_kind(filename, contents = nil)
        determine_kind_from_info(FileInfo.new(nil, filename, contents))
      end

      def determine_kind_from_info(info)
        mapping.each do |regex, details|
          if mapping_entry_match?(regex, details, info)
            return details[:kind]
          end
        end
        return nil
      end

      # calling this with contents=nil can produce less-informed
      # results, but kept for back compat
      def determine_can_have_lockfile(filename, contents = nil)
        determine_can_have_lockfile_from_info(FileInfo.new(nil, filename, contents))
      end

      def determine_can_have_lockfile_from_info(info)
        mapping.each do |regex, details|
          if mapping_entry_match?(regex, details, info)
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
