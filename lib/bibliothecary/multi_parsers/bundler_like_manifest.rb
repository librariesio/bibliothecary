module Bibliothecary
  module MultiParsers
    module BundlerLikeManifest
      # this takes parsed Bundler and Bundler-like (CocoaPods)
      # manifests and turns them into a list of dependencies.
      def parse_ruby_manifest(manifest)
        manifest.dependencies.inject([]) do |deps, dep|
          deps.push({
            name: dep.name,
            requirement: dep
              .requirement
              .requirements
              .sort_by(&:last)
              .map { |op, version| "#{op} #{version}" }
              .join(", "),
            type: dep.type
          })
        end.uniq
      end

      # Method to extract gems with a pattern from the Gemfile content
      def extract_gems_by_pattern(pattern, gemfile_content)
        gems = []
        puts "Gemfile Content from gem"
        puts gemfile_content
        gemfile_content.scan(pattern) do |gem_name, _require_option|
          gems << { name: gem_name.strip, type: :runtime }
        end

        gems
      end
    end
  end
end
