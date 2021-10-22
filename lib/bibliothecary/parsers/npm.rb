require 'json'

module Bibliothecary
  module Parsers
    class NPM
      include Bibliothecary::Analyser

      # Max depth to recurse into the "dependencies" property of package-lock.json
      PACKAGE_LOCK_JSON_MAX_DEPTH = 10

      def self.mapping
        {
          match_filename("package.json") => {
            kind: 'manifest',
            parser: :parse_manifest
          },
          match_filename("npm-shrinkwrap.json") => {
            kind: 'lockfile',
            parser: :parse_shrinkwrap
          },
          match_filename("yarn.lock") => {
            kind: 'lockfile',
            parser: :parse_yarn_lock
          },
          match_filename("package-lock.json") => {
            kind: 'lockfile',
            parser: :parse_package_lock
          },
          match_filename("npm-ls.json") => {
            kind: 'lockfile',
            parser: :parse_ls
          }
        }
      end

      def self.parse_shrinkwrap(file_contents)
        manifest = JSON.parse(file_contents)
        manifest.fetch('dependencies',[]).map do |name, requirement|
          {
            name: name,
            requirement: requirement["version"],
            type: 'runtime'
          }
        end
      end

      def self.parse_package_lock(file_contents)
        manifest = JSON.parse(file_contents)
        parse_package_lock_deps_recursively(manifest.fetch('dependencies', []))
      end

      def self.parse_package_lock_deps_recursively(dependencies, depth=1)
        dependencies.flat_map do |name, requirement|
          type = requirement.fetch("dev", false) ? 'development' : 'runtime'
          version = requirement.key?("from") ? requirement["from"][/#(?:semver:)?v?(.*)/, 1] : nil
          version ||= requirement["version"].split("#").last
          dependencies = depth >= PACKAGE_LOCK_JSON_MAX_DEPTH ? [] : parse_package_lock_deps_recursively(requirement.fetch('dependencies', []), depth + 1)

          [{
            name: name,
            requirement: version,
            type: type
          }] + dependencies
        end
      end

      def self.parse_manifest(file_contents)
        manifest = JSON.parse(file_contents)
        raise "appears to be a lockfile rather than manifest format" if manifest.key?('lockfileVersion')
        map_dependencies(manifest, 'dependencies', 'runtime') +
        map_dependencies(manifest, 'devDependencies', 'development')
      end

      def self.parse_yarn_lock(file_contents)
        response = Typhoeus.post("#{Bibliothecary.configuration.yarn_parser_host}/parse", body: file_contents)

        raise Bibliothecary::RemoteParsingError.new("Http Error #{response.response_code} when contacting: #{Bibliothecary.configuration.yarn_parser_host}/parse", response.response_code) unless response.success?

        json = JSON.parse(response.body, symbolize_names: true)
        json.uniq.map do |dep|
          {
            name: dep[:name],
            requirement: dep[:version],
            lockfile_requirement: dep[:requirement],
            type: dep[:type]
          }
        end
      end

      def self.parse_ls(file_contents)
        manifest = JSON.parse(file_contents)

        transform_tree_to_array(manifest.fetch('dependencies', {}))
      end

      private_class_method def self.transform_tree_to_array(deps_by_name)
        deps_by_name.map do |name, metadata|
          [
            {
              name: name,
              requirement: metadata["version"],
              lockfile_requirement: metadata.fetch("from", "").split('@').last,
              type: "runtime"
            }
          ] + transform_tree_to_array(metadata.fetch("dependencies", {}))
        end.flatten(1)
      end
    end
  end
end
