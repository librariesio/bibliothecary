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

      info_list = info_list.reject { |info| info.package_manager.nil? } if ignore_unparseable_files

      # Each package manager needs to see its entire list so it can
      # associate related manifests and lockfiles for example.
      analyses = package_managers.map do |pm|
        matching_infos = info_list.select { |info| info.package_manager == pm }
        pm.analyse_file_info(matching_infos, options: @options)
      end
      analyses = analyses.flatten.compact

      info_list.select { |info| info.package_manager.nil? }.each do |info|
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
      candidates = candidate_package_managers(info.relative_path)
      managers = candidates.select { |pm| pm.match_info?(info) }
      managers.empty? ? [nil] : managers
    end

    def package_managers
      @package_managers ||= Bibliothecary::Parsers.constants
        .map { |c| Bibliothecary::Parsers.const_get(c) }
        .sort_by { |c| c.to_s.downcase }
        .freeze
    end

    # Get candidate package managers for a file path using filename/extension index.
    # Falls back to all package managers for unindexed patterns.
    def candidate_package_managers(path)
      filename = File.basename(path)
      filename_lower = filename.downcase

      # Check exact filename match first (use fetch to avoid default block on frozen hash)
      candidates = filename_index.fetch(filename_lower, nil)
      return candidates if candidates

      # Check extension matches
      extension_index.each do |ext, ext_candidates|
        return ext_candidates if filename_lower.end_with?(ext)
      end

      # Fall back to all package managers for unindexed patterns
      package_managers
    end

    # Build an index mapping lowercase filenames to candidate parsers
    def filename_index
      @filename_index ||= build_filename_index
    end

    # Build an index mapping lowercase extensions to candidate parsers
    def extension_index
      @extension_index ||= build_extension_index
    end

    def build_filename_index
      index = {}

      package_managers.each do |pm|
        pm.mapping.each_key do |matcher|
          next unless matcher.is_a?(Proc)

          # Extract filenames from the matcher by testing common patterns
          extract_filenames_from_matcher(matcher).each do |filename|
            key = filename.downcase
            index[key] ||= []
            index[key] << pm
          end
        end
      end

      # Deduplicate and freeze
      index.transform_values! { |v| v.uniq.freeze }
      index.freeze
    end

    def build_extension_index
      index = {}

      package_managers.each do |pm|
        pm.mapping.each_key do |matcher|
          next unless matcher.is_a?(Proc)

          # Extract extensions from the matcher
          extract_extensions_from_matcher(matcher).each do |ext|
            key = ext.downcase
            index[key] ||= []
            index[key] << pm
          end
        end
      end

      # Deduplicate and freeze
      index.transform_values! { |v| v.uniq.freeze }
      index.freeze
    end

    # Try to extract filename patterns from a matcher proc
    def extract_filenames_from_matcher(matcher)
      filenames = []

      # Test common manifest filenames to see which ones match
      common_filenames.each do |filename|
        filenames << filename if matcher.call(filename)
      end

      filenames
    end

    # Try to extract extension patterns from a matcher proc
    def extract_extensions_from_matcher(matcher)
      extensions = []

      # Test common extensions
      common_extensions.each do |ext|
        test_file = "test#{ext}"
        extensions << ext if matcher.call(test_file)
      end

      extensions
    end

    def common_filenames
      @common_filenames ||= %w[
        package.json package-lock.json yarn.lock pnpm-lock.yaml npm-shrinkwrap.json npm-ls.json bun.lock
        Gemfile Gemfile.lock gems.rb gems.locked
        Cargo.toml Cargo.lock
        go.mod go.sum Gopkg.toml Gopkg.lock glide.yaml glide.lock Godeps
        requirements.txt Pipfile Pipfile.lock pyproject.toml poetry.lock setup.py
        pom.xml build.gradle build.gradle.kts ivy.xml
        composer.json composer.lock
        Podfile Podfile.lock
        pubspec.yaml pubspec.lock
        Package.swift Package.resolved
        Cartfile Cartfile.resolved Cartfile.private
        mix.exs mix.lock
        project.clj
        shard.yml shard.lock
        environment.yml environment.yaml
        bower.json
        elm-package.json elm.json
        vcpkg.json
        dub.json dub.sdl
        haxelib.json
        action.yml action.yaml
        Brewfile Brewfile.lock.json
        REQUIRE Project.toml Manifest.toml
        paket.lock packages.config Project.json Project.lock.json packages.lock.json project.assets.json
        DESCRIPTION
        META.json META.yml cpanfile
        cabal.config
        cyclonedx.json cyclonedx.xml
        dependencies.csv
        docker-compose.yml docker-compose.yaml Dockerfile
        MLmodel
        Modelfile
        dvc.yaml
        cog.yaml
        bentofile.yaml
        uv.lock pylock.toml
      ].freeze
    end

    def common_extensions
      @common_extensions ||= %w[
        .gemspec .nuspec .csproj .cabal .podspec .podspec.json
        .spdx .cdx.json .cdx.xml
      ].freeze
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

        add_matching_package_managers_for_file_to_list(file_list, info)
      end

      file_list
    end

    def load_file_info_list_from_paths(paths)
      file_list = []

      paths.each do |path|
        info = FileInfo.new(nil, path)

        next if ignored_files.include?(info.relative_path)

        add_matching_package_managers_for_file_to_list(file_list, info)
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

        add_matching_package_managers_for_file_to_list(file_list, info)
      end

      file_list
    end

    # Get a list of files in this path grouped by filename and repeated by package manager.
    #
    # @return [Array<Bibliothecary::RelatedFilesInfo>]
    def find_manifests(path)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list(path).reject { |info| info.package_manager.nil? })
    end

    def find_manifests_from_paths(paths)
      RelatedFilesInfo.create_from_file_infos(load_file_info_list_from_paths(paths).reject { |info| info.package_manager.nil? })
    end

    # file_path_contents_hash contains an Array of { file_path, contents }
    def find_manifests_from_contents(file_path_contents_hash)
      RelatedFilesInfo.create_from_file_infos(
        load_file_info_list_from_contents(
          file_path_contents_hash
        ).reject { |info| info.package_manager.nil? }
      )
    end

    # Read a manifest file and extract the list of dependencies from that file.
    def analyse_file(file_path, contents)
      contents = Bibliothecary.utf8_string(contents)

      # Use filename index to quickly find candidate parsers
      candidates = candidate_package_managers(file_path)
      candidates.select { |pm| pm.match?(file_path, contents) }.map do |pm|
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
      ignored_dirs_with_slash = ignored_dirs.map { |d| d.end_with?("/") ? d : "#{d}/" }
      allowed_file_list = file_list.reject do |f|
        ignored_dirs.include?(f) || f.start_with?(*ignored_dirs_with_slash)
      end
      allowed_file_list = allowed_file_list.reject { |f| ignored_files.include?(f) }

      # Fast path: use filename index directly for known manifest filenames
      # This avoids creating FileInfo objects and calling match? for each file
      manifests = []
      allowed_file_list.each do |file_path|
        filename_lower = File.basename(file_path).downcase

        # Check if this filename is in our index (known manifest)
        if filename_index.key?(filename_lower)
          manifests << file_path
          next
        end

        # Check extension index
        matched = extension_index.keys.any? { |ext| filename_lower.end_with?(ext) }
        manifests << file_path if matched
      end
      manifests.sort
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

    # Get the list of all package managers that apply to the file provided
    # as file_info, and, for each one, duplicate file_info and fill in
    # the appropriate package manager.
    def add_matching_package_managers_for_file_to_list(file_list, file_info)
      applicable_package_managers(file_info).each do |package_manager|
        new_file_info = file_info.dup
        new_file_info.package_manager = package_manager

        file_list.push(new_file_info)
      end
    end
  end
end

require_relative "runner/multi_manifest_filter"
