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
      def mapping_entry_match?(matcher, details, info)
        if matcher.call(info.relative_path)
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
        details = first_matching_mapping_details(FileInfo.new(nil, filename, contents))

        # this can be raised if we don't check match?/match_info?,
        # OR don't have the file contents when we check them, so
        # it turns out for example that a .xml file isn't a
        # manifest after all.
        raise Bibliothecary::FileParsingError.new("No parser for this file type", filename) unless details[:parser]

        # The `parser` method should raise an exception if the file is malformed,
        # should return empty [] if the file is fine but simply doesn't contain
        # any dependencies, and should never return nil. At the time of writing
        # this comment, some of the parsers return [] or nil to mean an error
        # which is confusing to users.
        send(details[:parser], contents)

      rescue Exception => e # default is StandardError but C bindings throw Exceptions
        # the C xml parser also puts a newline at the end of the message
        raise Bibliothecary::FileParsingError.new(e.message.strip, filename)
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
        first_matching_mapping_details(info).any?
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
        analyse_file_info(file_list.map { |full_path| FileInfo.new(folder_path, full_path) })
      end

      def analyse_file_info(file_info_list)
        matching_info = file_info_list
          .select(&method(:match_info?))

        matching_info.map do |info|
          analyse_contents_from_info(info)
            .merge(related_paths: related_paths(info, matching_info))
        end
      end

      def analyse_contents(filename, contents)
        analyse_contents_from_info(FileInfo.new(nil, filename, contents))
      end

      def analyse_contents_from_info(info)
        kind = determine_kind_from_info(info)
        dependencies = parse_file(info.relative_path, info.contents)
        dependencies = remove_ignored_deps(File.basename(info.relative_path), dependencies)

        Bibliothecary::Analyser::create_analysis(platform_name, info.relative_path, kind, dependencies || [])
      rescue Bibliothecary::FileParsingError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, kind, e.message)
      end

      def remove_ignored_deps(filename, dependencies)
        dependencies.reject { |dep|
          Bibliothecary.configuration.ignored_deps.key?(filename) &&
            Bibliothecary.configuration.ignored_deps[filename].any? { |re| dep[:name] =~ re }
        }
      end

      # calling this with contents=nil can produce less-informed
      # results, but kept for back compat
      def determine_kind(filename, contents = nil)
        determine_kind_from_info(FileInfo.new(nil, filename, contents))
      end

      def determine_kind_from_info(info)
        first_matching_mapping_details(info)
          .fetch(:kind, nil)
      end

      # calling this with contents=nil can produce less-informed
      # results, but kept for back compat
      def determine_can_have_lockfile(filename, contents = nil)
        determine_can_have_lockfile_from_info(FileInfo.new(nil, filename, contents))
      end

      def determine_can_have_lockfile_from_info(info)
        first_matching_mapping_details(info)
          .fetch(:can_have_lockfile, true)
      end

      def parse_ruby_manifest(manifest)
        manifest.dependencies.inject([]) do |deps, dep|
          deps.push({
            name: dep.name,
            requirement: dep
              .requirement
              .requirements
              .sort_by(&:last)
              .map { |op, version| "#{op} #{version}" }
              .join(", "),
            type: dep.type
          })
        end.uniq
      end

      def match_filename(filename, case_insensitive: false)
        if case_insensitive
          lambda { |path| path.downcase == filename.downcase || path.downcase.end_with?("/" + filename.downcase) }
        else
          lambda { |path| path == filename || path.end_with?("/" + filename) }
        end
      end

      def match_filenames(*filenames)
        lambda do |path|
          filenames.any? { |f| path == f } ||
            filenames.any? { |f| path.end_with?("/" + f) }
        end
      end

      def match_extension(filename, case_insensitive: false)
        if case_insensitive
          lambda { |path| path.downcase.end_with?(filename.downcase) }
        else
          lambda { |path| path.end_with?(filename) }
        end
      end

      private

      def related_paths(info, infos)
        return [] unless determine_can_have_lockfile_from_info(info)

        kind = determine_kind_from_info(info)
        relate_to_kind = first_matching_mapping_details(info)
          .fetch(:related_to, %w(manifest lockfile).reject { |k| k == kind })
        dirname = File.dirname(info.relative_path)

        infos
          .reject { |i| i == info }
          .select { |i| relate_to_kind.include?(determine_kind_from_info(i)) }
          .select { |i| File.dirname(i.relative_path) == dirname }
          .select(&method(:determine_can_have_lockfile_from_info))
          .map(&:relative_path)
          .sort
      end

      def first_matching_mapping_details(info)
        mapping
          .find { |matcher, details| mapping_entry_match?(matcher, details, info) }
          &.last || {}
      end
    end
  end
end
