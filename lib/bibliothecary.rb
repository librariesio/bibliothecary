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
  def self.analyse(path)
    info_list = load_file_info_list(path)
    package_managers.map{|pm| pm.analyse_file_info(info_list) }.flatten.compact
  end

  # deprecated; use load_file_info_list.
  def self.load_file_list(path)
    load_file_info_list(path).map { |info| info.absolute_path }
  end

  def self.load_file_info_list(path)
    file_list = []
    Find.find(path) do |subpath|
      Find.prune if FileTest.directory?(subpath) && ignored_dirs.include?(File.basename(subpath))
      file_list.push(FileInfo.new(path, subpath)) if FileTest.file?(subpath)
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
