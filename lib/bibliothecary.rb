require "bibliothecary/version"

Dir[File.expand_path('../bibliothecary/parsers/*.rb', __FILE__)].each do |file|
  require file
end

module Bibliothecary
  def self.analyse(path)
    cmd = `find #{path} -type f | grep -vE "#{ignored_files}"`
    file_list = cmd.split("\n")
    package_managers.map{|pm| pm.analyse(path, file_list) }.flatten.compact
  end

  def self.package_managers
    [
      Parsers::NPM,
      Parsers::Bower,
      Parsers::Packagist,
      Parsers::CPAN,
      Parsers::Meteor,
      Parsers::Cargo,
      Parsers::Pub,
      Parsers::Rubygems,
      Parsers::CocoaPods
    ]
  end

  def self.ignored_files
    ['.git'].join('|')
  end
end
