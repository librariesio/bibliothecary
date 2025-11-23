# frozen_string_literal: true

module Bibliothecary
  # A class that allows bibliothecary to run with multiple configurations at once, rather than with one global.
  # A runner is created every time a file is targeted to be parsed. Don't call
  # parse methods directory! Use a Runner.
  class Runner
    def initialize(configuration, parser_options: {})
      @configuration = configuration
      @options = {
        cache: {},
      }.merge(parser_options)
    end

    def analyse(path, ignore_unparseable_files: true)
      info_list = load_file_info_list(path)

      info_list = info_list.reject { |info| info.parser.nil? } if ignore_unparseable_files

      # Each package manager needs to see its entire list so it can
      # associate related manifests and lockfiles for example.
      analyses = parsers.map do |p|
        matching_infos = info_list.select { |info| info.parser == p }
        p.analyse_file_info(matching_infos, options: @options)
      end
      analyses = analyses.flatten.compact

      info_list.select { |info| info.parser.nil? }.each do |info|
        analyses.push(Bibliothecary::Analyser.create_error_analysis("unknown", info.relative_path, "unknown",
                                                                    "No parser for this file type"))
      end

      analyses
    end
    alias analyze analyse

    # deprecated; use load_file_info_list.
    def load_file_list(path)
      load_file_info_list(path).map(&:full_path)
    end

    def applicable_package_managers(info)
      raise "Runner#applicable_package_managers() has been removed in bibliothecary 15.0.0. Use applicable_parsers() instead, which now includes MultiParsers."
    end
    
    def applicable_parsers(info)
      managers = parsers.select { |p| p.match_info?(info) }
      managers.empty? ? [nil] : managers
    end

    def package_managers
      raise "Runner#applicable_package_managers() has been removed in bibliothecary 15.0.0. Use applicable_parsers() instead, which now includes MultiParsers."
    end

    def parsers
      Bibliothecary::Parsers.constants
        .map { |c| Bibliothecary::Parsers.const_get(c) }
        .sort_by { |c| c.to_s.downcase }
    end

    # Parses an array of format [{file_path: "", contents: ""},] to match
    # on both filename matches and on content_match patterns.
    #
    # @return [Array<Bibliothecary::FileInfo>] A list of FileInfo, one for each package manager match for each file
    def load_file_info_list_from_contents(file_path_contents_hash)
      file_list = []

      file_path_contents_hash.each do |file|
        info = FileInfo.new(nil, file[:file_path], file[:contents])

        next if ignored_files.include?(info.relative_path)

        add_matching_parsers_for_file_to_list(file_list, info)
      end

      file_list
    end

    def load_file_info_list_from_paths(paths)
      file_list = []

      paths.each do |path|
        info = FileInfo.new(nil, path)

        next if ignored_files.include?(info.relative_path)

        add_matching_parsers_for_file_to_list(file_list, info)
      end

      file_list
    end

    def load_file_info_list(path)
      file_list = []

      Find.find(path) do |subpath|
        info = FileInfo.new(path, subpath)

        Find.prune if FileTest.directory?(subpath) && ignored_dirs.include?(info.relative_path)
        next unless FileTest.file?(subpath)
        next if ignored_files.include?(info.relative_path)

        add_matching_parsers_for_file_to_list(file_list, info)
      end

      file_list
    end

    # Get a list of files in this path grouped by filename and repeated by package manager.
    #
    # @return [Array<Bibliothecary::RelatedFilesInfo>]
    def find_manifests(path)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list(path).reject { |info| info.parser.nil? })
    end

    def find_manifests_from_paths(paths)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list_from_paths(paths).reject { |info| info.parser.nil? })
    end

    # file_path_contents_hash contains an Array of { file_path, contents }
    def find_manifests_from_contents(file_path_contents_hash)
      RelatedFilesInfo.create_from_file_infos(
        load_file_info_list_from_contents(
          file_path_contents_hash
        ).reject { |info| info.parser.nil? }
      )
    end

    # Read a manifest file and extract the list of dependencies from that file.
    def analyse_file(file_path, contents)
      contents = Bibliothecary.utf8_string(contents)

      parsers.select { |p| p.match?(file_path, contents) }.map do |p|
        p.analyse_contents(file_path, contents, options: @options)
      end.flatten.uniq.compact
    end
    alias analyze_file analyse_file

    # this skips manifests sometimes because it doesn't look at file
    # contents and can't establish from only regexes that the thing
    # is a manifest. We exclude rather than include ambiguous filenames
    # because this API is used by libraries.io and we don't want to
    # download all .xml files from GitHub.
    def identify_manifests(file_list)
      ignored_dirs_with_slash = ignored_dirs.map { |d| d.end_with?("/") ? d : "#{d}/" }
      allowed_file_list = file_list.reject do |f|
        ignored_dirs.include?(f) || f.start_with?(*ignored_dirs_with_slash)
      end
      allowed_file_list = allowed_file_list.reject { |f| ignored_files.include?(f) }
      parsers.map do |p|
        # (skip rubocop false positive, since match? is a custom method)
        allowed_file_list.select do |file_path| # rubocop:disable Style/SelectByRegexp
          # this is a call to match? without file contents, which will skip
          # ambiguous filenames that are only possibly a manifest
          p.match?(file_path)
        end
      end.flatten.uniq.compact
    end

    def ignored_dirs
      @configuration.ignored_dirs
    end

    def ignored_files
      @configuration.ignored_files
    end

    # We don't know what file groups are in multi file manifests until
    # we process them. In those cases, process those, then reject the
    # RelatedFilesInfo objects that aren't in the manifest.
    #
    # This means we're likely analyzing these files twice in processing,
    # but we need that accurate package manager information.
    def filter_multi_manifest_entries(path, related_files_info_entries)
      MultiManifestFilter.new(path: path, related_files_info_entries: related_files_info_entries, runner: self).results
    end

    private

    def add_matching_package_managers_for_file_to_list(file_list, file_info)
      raise "Runner#add_matching_package_managers_for_file_to_list() has been removed in bibliothecary 15.0.0. Use add_matching_parsers_for_file_to_list() instead, which now includes MultiParsers."
    end
    
    # Get the list of all package managers that apply to the file provided
    # as file_info, and, for each one, duplicate file_info and fill in
    # the appropriate package manager.
    def add_matching_parsers_for_file_to_list(file_list, file_info)
      applicable_parsers(file_info).each do |parser|
        new_file_info = file_info.dup
        new_file_info.parser = parser

        file_list.push(new_file_info)
      end
    end
  end
end

require_relative "runner/multi_manifest_filter"
