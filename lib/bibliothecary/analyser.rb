require_relative './analyser/matchers.rb'
require_relative './analyser/determinations.rb'
require_relative './analyser/analysis.rb'

module Bibliothecary
  module Analyser
    def self.create_error_analysis(platform_name, relative_path, kind, message)
      {
        platform: platform_name,
        path: relative_path,
        dependencies: nil,
        kind: kind,
        success: false,
        error_message: message
      }
    end

    def self.create_analysis(platform_name, relative_path, kind, dependencies)
      {
        platform: platform_name,
        path: relative_path,
        dependencies: dependencies,
        kind: kind,
        success: true
      }
    end

    def self.included(base)
      base.extend(ClassMethods)

      # Group like-methods into separate modules for easier comprehension.
      base.extend(Bibliothecary::Analyser::Matchers)
      base.extend(Bibliothecary::Analyser::Determinations)
      base.extend(Bibliothecary::Analyser::Analysis)
    end

    module ClassMethods
      def generic?
        platform_name == "generic"
      end

      def platform_name
        self.name.to_s.split('::').last.downcase
      end

      def map_dependencies(hash, key, type)
        hash.fetch(key,[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement,
            type: type
          }
        end
      end

      # Add a MultiParser module to a Parser class. This extends the
      # self.mapping method on the parser to include the multi parser's
      # files to watch for, and it extends the Parser class with
      # the multi parser for you.
      #
      # @param klass [Class] A Bibliothecary::MultiParsers class
      def add_multi_parser(klass)
        raise "No mapping found! You should place the add_multi_parser call below def self.mapping." unless respond_to?(:mapping)

        original_mapping = self.mapping

        define_singleton_method(:mapping) do
          original_mapping.merge(klass.mapping)
        end

        send(:extend, klass)
      end
    end
  end
end
