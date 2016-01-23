require "bibliothecary/version"
require "bibliothecary/npm"
require "bibliothecary/bower"
require "bibliothecary/packagist"
require "bibliothecary/cpan"
require "bibliothecary/meteor"

module Bibliothecary
  def self.analyse(path)
    cmd = `find #{path} -type f | grep -vE "#{ignored_files}"`
    file_list = cmd.split("\n")
    package_managers.map{|pm| pm.analyse(path, file_list) }.flatten.compact
  end

  def self.package_managers
    [
      NPM,
      Bower,
      Packagist,
      CPAN,
      Meteor
    ]
  end

  def self.ignored_files
    ['.git'].join('|')
  end
end
