require 'bibliothecary/version'
require 'bibliothecary'
require 'commander'

module Bibliothecary
  class CLI
    include Commander::Methods

    def run
      program :name, 'Bibliothecary'
      program :version, Bibliothecary::VERSION
      program :description, 'Parse dependency information from a file or folder of code'

      command(:list) do |c|
        c.syntax = 'bibliothecary list'
        c.description = 'List dependencies'
        c.option("--path FILENAME", String, "Path to file/folder to analyse")
        c.action do |args, options|
          output = Bibliothecary.analyse(options.path)
          output.each do |manifest|
            puts "#{manifest[:path]} (#{manifest[:platform]})"
            manifest[:dependencies].group_by{|d| d[:type] }.each do |type, deps|
              puts "  #{type}"
              deps.each do |dep|
                puts "    #{dep[:name]} #{dep[:requirement]}"
              end
              puts
            end
            puts
          end
        end
      end

      run!
    end
  end
end
