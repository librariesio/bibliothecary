module Bibliothecary
  module Analyser
    module Analysis
      # Convenience method to create FileInfo objects from folder path and
      # file list.
      #
      # @param folder_path [String]
      # @param file_list [Array<String>]
      # @param options [Hash]
      def analyse(folder_path, file_list, options: {})
        analyse_file_info(file_list.map { |full_path| FileInfo.new(folder_path, full_path) }, options: options)
      end
      alias analyze analyse

      # Analyze a set of FileInfo objects and extract manifests from them all.
      #
      # @params file_info_list [Array<FileInfo>]
      def analyse_file_info(file_info_list, options: {})
        matching_info = file_info_list
          .select(&method(:match_info?))

        matching_info.flat_map do |info|
          analyse_contents_from_info(info, options: options)
            .merge(related_paths: related_paths(info, matching_info))
        end
      end
      alias analyze_file_info analyse_file_info

      def analyse_contents(filename, contents, options: {})
        analyse_contents_from_info(FileInfo.new(nil, filename, contents), options: options)
      end
      alias analyze_contents analyse_contents

      # This is the place a parsing operation will eventually end up.
      #
      # @param info [FileInfo]
      def analyse_contents_from_info(info, options: {})
        # If your Parser needs to return multiple responses for one file, please override this method
        # For example see conda.rb
        kind = determine_kind_from_info(info)
        dependencies = parse_file(info.relative_path, info.contents, options: options)

        dependencies_to_analysis(info, kind, dependencies)
      rescue Bibliothecary::FileParsingError => e
        Bibliothecary::Analyser::create_error_analysis(platform_name, info.relative_path, kind, e.message)
      end
      alias analyze_contents_from_info analyse_contents_from_info

      def dependencies_to_analysis(info, kind, dependencies)
        dependencies = dependencies || [] # work around any legacy parsers that return nil
        if generic?
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

      # Call the matching parse class method for this file with
      # these contents
      def parse_file(filename, contents, options: {})
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
        send(details[:parser], contents, options: options.merge(filename: filename))

      rescue Exception => e # default is StandardError but C bindings throw Exceptions
        # the C xml parser also puts a newline at the end of the message
        location = e.backtrace_locations[0]
          .to_s
          .then { |l| l =~ /bibliothecary\// ? l.split("bibliothecary/").last : l.split("gems/").last }
        raise Bibliothecary::FileParsingError.new("#{e.message.strip} (#{location})", filename)
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
    end
  end
end
