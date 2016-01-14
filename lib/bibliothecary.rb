require "bibliothecary/version"
require "bibliothecary/npm"
require "bibliothecary/bower"

module Bibliothecary
  def self.analyse(path)
    cmd = `find #{path} -type f | grep -vE "#{ignored_files}"`
    p path
    file_list = cmd.split("\n").map{|l| l.gsub(path, '') }
    p file_list
    package_managers.map{|pm| pm.analyse(file_list) }.compact.flatten
  end

  def self.package_managers
    [
      NPM,
      Bower
    ]
  end

  def self.ignored_files
    ['.git'].join('|')
  end
end
