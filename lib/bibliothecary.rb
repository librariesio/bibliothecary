require "bibliothecary/version"
require "bibliothecary/analyser"
require "bibliothecary/configuration"
require "bibliothecary/exceptions"
require "bibliothecary/file_info"
require "find"

Dir[File.expand_path('../bibliothecary/parsers/*.rb', __FILE__)].each do |file|
  require file
end

module Bibliothecary
  def self.analyse(path, ignore_unparseable_files: true)
    info_list = load_file_info_list(path)

    info_list = info_list.reject { |info| info.package_manager.nil? } if ignore_unparseable_files

    # Each package manager needs to see its entire list so it can
    # associate related manifests and lockfiles for example.
    analyses = package_managers.map do |pm|
      matching_infos = info_list.select { |info| info.package_manager == pm }
      pm.analyse_file_info(matching_infos)
    end
    analyses = analyses.flatten.compact

    info_list.select { |info| info.package_manager.nil? }.each do |info|
      analyses.push(Bibliothecary::Analyser::create_error_analysis('unknown', info.relative_path, 'unknown',
                                                                   'No parser for this file type'))
    end

    analyses
  end

  # deprecated; use load_file_info_list.
  def self.load_file_list(path)
    load_file_info_list(path).map { |info| info.full_path }
  end

  def self.init_package_manager(info)
    # set the package manager on each info
    matches = package_managers.select { |pm| pm.match_info?(info) }

    info.package_manager = matches[0] if matches.length == 1

    # this is a bug at the moment if it's raised (we don't handle it sensibly)
    raise "Multiple package managers fighting over #{info.relative_path}: #{matches.map(&:to_s)}" if matches.length > 1
  end

  def self.load_file_info_list(path)
    file_list = []
    Find.find(path) do |subpath|
      Find.prune if FileTest.directory?(subpath) && ignored_dirs.include?(File.basename(subpath))
      next unless FileTest.file?(subpath)

      info = FileInfo.new(path, subpath)
      init_package_manager(info)

      file_list.push(info)
    end
    file_list
  end

  def self.analyse_file(file_path, contents)
    package_managers.select { |pm| pm.match?(file_path, contents) }.map do |pm|
      pm.analyse_contents(file_path, contents)
    end.flatten.uniq.compact
  end

  # this skips manifests sometimes because it doesn't look at file
  # contents and can't establish from only regexes that the thing
  # is a manifest. We exclude rather than include ambiguous filenames
  # because this API is used by libraries.io and we don't want to
  # download all .xml files from GitHub.
  def self.identify_manifests(file_list)
    allowed_file_list = file_list.reject{|f| f.start_with?(*ignored_dirs) }
    package_managers.map do |pm|
      allowed_file_list.select do |file_path|
        # this is a call to match? without file contents, which will skip
        # ambiguous filenames that are only possibly a manifest
        pm.match?(file_path)
      end
    end.flatten.uniq.compact
  end

  def self.package_managers
    Bibliothecary::Parsers.constants.map{|c| Bibliothecary::Parsers.const_get(c) }.sort_by{|c| c.to_s.downcase }
  end
  def self.ignored_dirs
    configuration.ignored_dirs
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
