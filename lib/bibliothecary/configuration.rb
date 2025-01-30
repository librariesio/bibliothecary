# frozen_string_literal: true

module Bibliothecary
  class Configuration
    attr_accessor :ignored_dirs, :ignored_files, :carthage_parser_host, :clojars_parser_host, :mix_parser_host, :conda_parser_host, :swift_parser_host, :cabal_parser_host

    def initialize
      @ignored_dirs = [".git", "node_modules", "bower_components", "vendor", "dist"]
      @ignored_files = []
      @carthage_parser_host = "https://carthage.libraries.io"
      @clojars_parser_host  = "https://clojars.libraries.io"
      @mix_parser_host      = "https://mix.libraries.io"
      @swift_parser_host    = "http://swift.libraries.io"
      @cabal_parser_host    = "http://cabal.libraries.io"
    end
  end
end
