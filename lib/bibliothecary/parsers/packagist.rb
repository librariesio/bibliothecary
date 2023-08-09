require 'json'

module Bibliothecary
  module Parsers
    class Packagist
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("composer.json") => {
            kind: 'manifest',
            parser: :parse_manifest
          },
          match_filename("composer.lock") => {
            kind: 'lockfile',
            parser: :parse_lockfile
          }
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_lockfile(file_contents, options: {})
        manifest = JSON.parse file_contents
        manifest.fetch('packages',[]).map do |dependency|
          {
            name: dependency["name"],
            requirement: dependency["version"],
            type: "runtime"
          }.tap do |result|
            # Store Drupal version if Drupal, but include the original manifest version for reference
            result[:original_requirement], result[:requirement] = result[:requirement], dependency.dig("source", "reference") if is_drupal_module(dependency)
          end
        end + manifest.fetch('packages-dev',[]).map do |dependency|
          {
            name: dependency["name"],
            requirement: dependency["version"],
            type: "development"
          }.tap do |result|
            # Store Drupal version if Drupal, but include the original manifest version for reference
            result[:original_requirement], result[:requirement] = result[:requirement], dependency.dig("source", "reference") if is_drupal_module(dependency)
          end
        end
      end

      def self.parse_manifest(file_contents, options: {})
        manifest = JSON.parse file_contents
        map_dependencies(manifest, 'require', 'runtime') +
        map_dependencies(manifest, 'require-dev', 'development')
      end

      # Drupal hosts its own Composer repository, where its "modules" are indexed and searchable. The best way to
      # confirm that Drupal's repo is being used is if its in the "repositories" in composer.json
      # (https://support.acquia.com/hc/en-us/articles/360048081273-Using-Composer-to-manage-dependencies-in-Drupal-8-and-9),
      # but you may only have composer.lock, so we test if the type is "drupal-*" (e.g. "drupal-module" or "drupal-theme")
      # The Drupal team also setup its own mapper of Composer semver -> Drupal tool-specfic versions
      # (https://www.drupal.org/project/project_composer/issues/2622450),
      # so we return the Drupal requirement instead of semver requirement if it's here
      # (https://www.drupal.org/docs/develop/using-composer/using-composer-to-install-drupal-and-manage-dependencies#s-about-semantic-versioning)
      private_class_method def self.is_drupal_module(dependency)
        dependency["type"] =~ /drupal/ && dependency.dig("source", "reference")
      end
    end
  end
end
