module Bibliothecary
  module MultiParsers
    module TargetFramework
      TARGET_FRAMEWORKS = {
        '.NET': ['net11', 'net20', 'net35', 'net40', 'net403', 'net45', 'net451', 'net452', 'net46', 'net461', 'net462', 'net47', 'net471', 'net472', 'net48'],
        '.NET Core': ['netcoreapp1.0', 'netcoreapp1.1', 'netcoreapp2.0', 'netcoreapp2.1', 'netcoreapp2.2', 'netcoreapp3.0', 'netcoreapp3.1', 'net5.0', 'net6.0', 'net7.0']
      }.freeze

      def identify_target_framework(tfm)
        matching_framework = find_matching_framework(tfm)
        return if matching_framework.nil?

        version = extract_version(tfm)
        {
          name: matching_framework.to_s,
          requirement: version,
          type: 'runtime'
        }
      rescue => e
        e.message
      end

      private

      def find_matching_framework(tfm)
        target_frameworks = TARGET_FRAMEWORKS.dup
        target_frameworks.find { |_framework, versions| versions.any? { |version| tfm.start_with?(version) } }&.first
      end

      def extract_version(tfm)
        version = tfm.scan(/\d+/).join('.')
        version = version[0...-1] if version.end_with?('.')
        version.include?('.') ? version : version.chars.join('.')
      end
    end
  end
end
