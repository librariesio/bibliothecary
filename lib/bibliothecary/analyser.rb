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
      def generic?
        platform_name == "generic"
      end

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

      # Call the matching parse class method for this file with
      # these contents
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
        send(details[:parser], contents, options: {})

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
      alias analyze analyse

      def analyse_file_info(file_info_list)
        matching_info = file_info_list
          .select(&method(:match_info?))

        matching_info.flat_map do |info|
          analyse_contents_from_info(info)
            .merge(related_paths: related_paths(info, matching_info))
        end
      end
      alias analyze_file_info analyse_file_info

      def analyse_contents(filename, contents)
        analyse_contents_from_info(FileInfo.new(nil, filename, contents))
      end
      alias analyze_contents analyse_contents

      def dependencies_to_analysis(info, kind, dependencies)
        dependencies = dependencies || [] # work around any legacy parsers that return nil
        if generic?
          analyses = []
          grouped = dependencies.group_by { |dep| dep[:platform] }
          all_analyses = grouped.keys.map do |platform|
            deplatformed_dependencies = grouped[platform].map { |d| d.delete(:platform); d }
            Bibliothecary::Analyser::create_analysis(platform, info.relative_path, kind, deplatformed_dependencies)
          end
          # this is to avoid a larger refactor for the time being. The larger refactor
          # needs to make analyse_contents return multiple analysis, or add another
          # method that can return multiple and deprecate analyse_contents, perhaps.
          raise "File contains zero or multiple platforms, currently must have exactly one" if all_analyses.length != 1
          all_analyses.first
        else
          Bibliothecary::Analyser::create_analysis(platform_name, info.relative_path, kind, dependencies)
        end
      end

      def analyse_contents_from_info(info)
        # If your Parser needs to return multiple responses for one file, please override this method
        # For example see conda.rb
        kind = determine_kind_from_info(info)
        dependencies = parse_file(info.relative_path, info.contents)

        dependencies_to_analysis(info, kind, dependencies)
      rescue Bibliothecary::FileParsingError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, kind, e.message)
      end
      alias analyze_contents_from_info analyse_contents_from_info

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

      # Add a MultiParser module to a Parser class. This extends the
      # self.mapping method on the parser to include the multi parser's
      # files to watch for, and it extends the Parser class with
      # the multi parser for you.
      #
      # @param klass [Class] A Bibliothecary::MultiParsers class
      def add_multi_parser(klass)
        raise "No mapping found! You should place the add_multi_parser call below def self.mapping." unless respond_to?(:mapping)

        original_mapping = self.mapping

        define_singleton_method(:mapping) do
          original_mapping.merge(klass.mapping)
        end

        send(:extend, klass)
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
