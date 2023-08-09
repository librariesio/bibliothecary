require "bibliothecary/version"
require "bibliothecary/analyser"
require "bibliothecary/configuration"
require "bibliothecary/runner"
require "bibliothecary/exceptions"
require "bibliothecary/file_info"
require "bibliothecary/related_files_info"
require "bibliothecary/purl_util"
require "find"
require "tomlrb"

Dir[File.expand_path('../bibliothecary/multi_parsers/*.rb', __FILE__)].each do |file|
  require file
end
Dir[File.expand_path('../bibliothecary/parsers/*.rb', __FILE__)].each do |file|
  require file
end

module Bibliothecary
  VERSION_OPERATORS = /[~^<>*"]/

  def self.analyse(path, ignore_unparseable_files: true)
    runner.analyse(path, ignore_unparseable_files: ignore_unparseable_files)
  end

  # deprecated; use load_file_info_list.
  def self.load_file_list(path)
    runner.load_file_list(path)
  end

  def self.applicable_package_managers(info)
    runner.applicable_package_managers(info)
  end

  def self.load_file_info_list(path)
    runner.load_file_info_list(path)
  end

  def self.load_file_info_list_from_paths(paths)
    runner.load_file_info_list_from_paths(paths)
  end

  def self.load_file_info_list_from_contents(file_path_contents_hash)
    runner.load_file_info_list_from_contents(file_path_contents_hash)
  end

  def self.analyse_file(file_path, contents)
    runner.analyse_file(file_path, contents)
  end

  def self.identify_manifests(file_list)
    runner.identify_manifests(file_list)
  end

  def self.package_managers
    runner.package_managers
  end

  def self.find_manifests(path)
    runner.find_manifests(path)
  end

  def self.find_manifests_from_paths(paths)
    runner.find_manifests_from_paths(paths)
  end

  def self.find_manifests_from_contents(file_path_contents_hash)
    runner.find_manifests_from_contents(file_path_contents_hash)
  end

  def self.ignored_dirs
    configuration.ignored_dirs
  end

  def self.ignored_files
    configuration.ignored_files
  end

  def self.utf8_string(string)
    string
      .dup # ensure we don't have a frozen string
      .force_encoding("UTF-8") # treat all strings as utf8
      .sub(/^\xEF\xBB\xBF/, '') # remove any Byte Order Marks so JSON, etc don't fail while parsing them.
  end

  class << self
    attr_writer :configuration
    alias analyze analyse
    alias analyze_file analyse_file
  end

  def self.runner
    configuration
    @runner
  end

  def self.configuration
    @configuration ||= Configuration.new
    @runner = Runner.new(@configuration)
    @configuration
  end

  def self.reset
    @configuration = Configuration.new
    @runner = Runner.new(@configuration)
  end

  def self.configure
    yield(configuration)
  end
end
