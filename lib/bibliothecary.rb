require "bibliothecary/version"
require "bibliothecary/analyser"
require "bibliothecary/configuration"
require "bibliothecary/exceptions"
require "find"

Dir[File.expand_path('../bibliothecary/parsers/*.rb', __FILE__)].each do |file|
  require file
end

module Bibliothecary
  def self.analyse(path)
    file_list = []
    Find.find(path) do |subpath|
      Find.prune if FileTest.directory?(subpath) && ignored_dirs.include?(File.basename(subpath))
      file_list.push(subpath)
    end
    package_managers.map{|pm| pm.analyse(path, file_list) }.flatten.compact
  end

  def self.analyse_file(file_path, contents)
    package_managers.map do |pm|
      pm.analyse_contents(file_path, contents)
    end.flatten.uniq.compact
  end

  def self.identify_manifests(file_list)
    allowed_file_list = file_list.reject{|f| f.start_with?(*ignored_dirs) }
    package_managers.map do |pm|
      allowed_file_list.select do |file_path|
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
