module Bibliothecary
  module MultiParsers
    module TargetFramework
      def identify_target_framework(tfm)
        target_frameworks = {
            '.NET' => ['net11', 'net20', 'net35', 'net40', 'net403', 'net45', 'net451', 'net452', 'net46', 'net461', 'net462', 'net47', 'net471', 'net472', 'net48'],
            '.NET Core' => ['netcoreapp1.0', 'netcoreapp1.1', 'netcoreapp2.0', 'netcoreapp2.1', 'netcoreapp2.2', 'netcoreapp3.0', 'netcoreapp3.1', 'net5.0*', 'net6.0*', 'net7.0*']
          }

          # Find the matching target framework in the hash
          matching_framework = target_frameworks.find { |_framework, versions| versions.any? { |version| tfm.start_with?(version.gsub('*', '')) } }
          return if matching_framework.nil?

          {
            name: matching_framework[0],
            requirement: nil,
            type: 'runtime'
          }
      rescue
      end
    end
  end
end
