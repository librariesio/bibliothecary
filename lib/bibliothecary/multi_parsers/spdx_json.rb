require "package_url"

module Bibliothecary
  module MultiParsers
    module SpdxJson
      include Bibliothecary::Analyser
      include Bibliothecary::Analyser::TryCache

      NoEntries = Class.new(StandardError)

      def self.mapping
        {
          match_extension(".json") => {
            content_matcher: :spdx_json_file?,
            kind: "lockfile",
            parser: :parse_spdx_json,
            ungroupable: true,
          },
        }
      end

      def spdx_json_file?(file_contents)
        manifest = JSON.parse(file_contents)
        spdx_id = manifest.fetch("SPDXID")
        spdx_version = manifest.fetch("spdxVersion")
        return spdx_id == "SPDXRef-DOCUMENT" && !spdx_version.nil?
      rescue Exception # rubocop:disable Lint/RescueException
        # We rescue exception here since native libs can throw a non-StandardError
        # We don't want to throw errors during the matching phase, only during
        # parsing after we match.
        false
      end

      def parse_spdx_json(file_contents, options: {})
        entries = try_cache(options, options[:filename]) do
          parse_spdx_json_file_contents(file_contents)
        end

        raise NoEntries if entries.empty?

        entries[platform_name.to_sym]
      end

      def get_platform(purl_string)
        platform = PackageURL.parse(purl_string).type

        Bibliothecary::PURL_TYPE_MAPPING[platform]
      end

      def parse_spdx_json_file_contents(file_contents)
        entries = {}
        manifest = JSON.parse(file_contents)

        manifest["packages"]&.each do |package|
          package_name = package["name"]
          package_version = package["versionInfo"]

          platform = nil
          package["externalRefs"]&.each do |ref|
            if ref["referenceType"] == "purl"
              purl = ref["referenceLocator"]
              platform ||= get_platform(purl)
            end
          end

          if package_name && package_version && platform
            entries[platform.to_sym] ||= []
            entries[platform.to_sym] << Dependency.new(
              name: package_name,
              requirement: package_version,
              type: "lockfile",
            )
          end
        end

        entries
      end
    end
  end
end
