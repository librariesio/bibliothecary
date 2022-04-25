module Bibliothecary
  # A class that allows bibliothecary to run with multiple configurations at once, rather than with one global.
  # A runner is created every time a file is targeted to be parsed. Don't call
  # parse methods directory! Use a Runner.
  class Runner

    def initialize(configuration)
      @configuration = configuration
      @options = {
        cache: {}
      }
    end

    def analyse(path, ignore_unparseable_files: true)
      info_list = load_file_info_list(path)

      info_list = info_list.reject { |info| info.package_manager.nil? } if ignore_unparseable_files

      # Each package manager needs to see its entire list so it can
      # associate related manifests and lockfiles for example.
      analyses = package_managers.map do |pm|
        matching_infos = info_list.select { |info| info.package_manager == pm }
        pm.analyse_file_info(matching_infos, options: @options)
      end
      analyses = analyses.flatten.compact

      info_list.select { |info| info.package_manager.nil? }.each do |info|
        analyses.push(Bibliothecary::Analyser::create_error_analysis('unknown', info.relative_path, 'unknown',
                                                                     'No parser for this file type'))
      end

      analyses
    end
    alias analyze analyse

    # deprecated; use load_file_info_list.
    def load_file_list(path)
      load_file_info_list(path).map { |info| info.full_path }
    end

    def applicable_package_managers(info)
      managers = package_managers.select { |pm| pm.match_info?(info) }
      managers.length > 0 ? managers : [nil]
    end

    def package_managers
      Bibliothecary::Parsers.constants.map{|c| Bibliothecary::Parsers.const_get(c) }.sort_by{|c| c.to_s.downcase }
    end

    def load_file_info_list_from_contents(file_path_contents_hash)
      # Parses an array of format [{file_path: "", contents: ""},] to match
      #  on both filename matches, and one content_match patterns.
      file_list = []

      file_path_contents_hash.each do |file|
        info = FileInfo.new(nil, file[:file_path], file[:contents])

        next if ignored_files.include?(info.relative_path)

        add_files_to_list(file_list, info)
      end

      file_list
    end

    def load_file_info_list_from_paths(paths)
      file_list = []

      paths.each do |path|
        info = FileInfo.new(nil, path)

        next if ignored_files.include?(info.relative_path)

        add_files_to_list(file_list, info)
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

        add_files_to_list(file_list, info)
      end

      file_list
    end

    def find_manifests(path)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list(path).reject { |info| info.package_manager.nil? })
    end

    def find_manifests_from_paths(paths)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list_from_paths(paths).reject { |info| info.package_manager.nil? })
    end

    def find_manifests_from_contents(file_path_contents_hash)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list_from_contents(file_path_contents_hash).reject { |info| info.package_manager.nil? })
    end

    def analyse_file(file_path, contents)
      package_managers.select { |pm| pm.match?(file_path, contents) }.map do |pm|
        pm.analyse_contents(file_path, contents, options: @options)
      end.flatten.uniq.compact
    end
    alias analyze_file analyse_file

    # this skips manifests sometimes because it doesn't look at file
    # contents and can't establish from only regexes that the thing
    # is a manifest. We exclude rather than include ambiguous filenames
    # because this API is used by libraries.io and we don't want to
    # download all .xml files from GitHub.
    def identify_manifests(file_list)
      ignored_dirs_with_slash = ignored_dirs.map { |d| if d.end_with?("/") then d else d + "/" end }
      allowed_file_list = file_list.reject do |f|
        ignored_dirs.include?(f) || f.start_with?(*ignored_dirs_with_slash)
      end
      allowed_file_list = allowed_file_list.reject{|f| ignored_files.include?(f)}
      package_managers.map do |pm|
        allowed_file_list.select do |file_path|
          # this is a call to match? without file contents, which will skip
          # ambiguous filenames that are only possibly a manifest
          pm.match?(file_path)
        end
      end.flatten.uniq.compact
    end

    def ignored_dirs
      @configuration.ignored_dirs
    end

    def ignored_files
      @configuration.ignored_files
    end

    private

    def add_files_to_list(file_list, info)
      applicable_package_managers(info).each do |package_manager|
        file = info.dup
        file.package_manager = package_manager

        file_list.push(file)
      end
    end
  end
end
