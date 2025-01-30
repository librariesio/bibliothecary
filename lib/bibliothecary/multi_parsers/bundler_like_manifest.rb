# frozen_string_literal: true

module Bibliothecary
  module MultiParsers
    module BundlerLikeManifest
      # this takes parsed Bundler and Bundler-like (CocoaPods)
      # manifests and turns them into a list of dependencies.
      def parse_ruby_manifest(manifest, source = nil)
        manifest.dependencies.inject([]) do |deps, dep|
          deps.push(Dependency.new(
                      name: dep.name,
                      requirement: dep
                        .requirement
                        .requirements
                        .sort_by(&:last)
                        .map { |op, version| "#{op} #{version}" }
                        .join(", "),
                      type: dep.type.to_s,
                      source:
                    ))
        end.uniq
      end
    end
  end
end
