require "bibliothecary/version"
require "bibliothecary/analyser"

Dir[File.expand_path('../bibliothecary/parsers/*.rb', __FILE__)].each do |file|
  require file
end

module Bibliothecary
  def self.analyse(path)
    cmd = `find #{path} -type f | grep -vE "#{ignored_files_regex}"`
    file_list = cmd.split("\n").sort
    package_managers.map{|pm| pm.analyse(path, file_list) }.flatten.compact
  end

  def self.analyse_file(file_path, contents)
    package_managers.map do |pm|
      pm.analyse_contents(file_path, contents)
    end.flatten.uniq.compact
  end

  def self.identify_manifests(file_list)
    allowed_file_list = file_list.reject{|f| f.start_with?(*ignored_files) }
    package_managers.map do |pm|
      allowed_file_list.select do |file_path|
        pm.match?(file_path)
      end
    end.flatten.uniq.compact
  end

  def self.package_managers
    Bibliothecary::Parsers.constants.map{|c| Bibliothecary::Parsers.const_get(c) }.sort_by{|c| c.to_s.downcase }
  end

  def self.ignored_files
    ['.git', 'node_modules', 'bower_components', 'spec/fixtures', 'vendor', 'dist']
  end

  def self.ignored_files_regex
    ignored_files.join('|')
  end
end
