module Bibliothecary
  module MultiParsers
    module DotnetFramework
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
      rescue
        {}
      end

      def identify_web_framework(packages)
        asp_net_core_package = find_asp_net_core_package(packages)
        asp_net_package = find_asp_net_package(packages)

        web_frameworks = []
        web_frameworks << asp_net_core_package unless asp_net_core_package.nil?
        web_frameworks << asp_net_package unless asp_net_package.nil?

        web_frameworks
      end

      def dotnet_framework_version(tfm)
        tfm.scan(/\d/).join('.')
      rescue
        nil
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

      def find_asp_net_core_package(packages)
        asp_net_core_package = nil

        packages.each do |package|
          if ["Microsoft.AspNetCore.Mvc","Microsoft.AspNetCore.App","Microsoft.AspNetCore"].include? package[:name]
            asp_net_core_package = { name: "ASP.NET Core", requirement: package[:requirement], type: "runtime" } if package[:requirement] != "*"
            break
          end
        end

        if asp_net_core_package.nil?
          dotnet_core_package = packages.find { |package| package[:name] == ".NET Core" }
          asp_net_core_package = { name: "ASP.NET Core", requirement: dotnet_core_package[:requirement], type: "runtime" } unless dotnet_core_package.nil?
        end

        asp_net_core_package
      end

      def find_asp_net_package(packages)
        asp_net_package = nil

        packages.each do |package|
          if package[:name] == "Microsoft.AspNet.Mvc"
            asp_net_package = { name: "ASP.NET", requirement: package[:requirement], type: "runtime" }
            break
          end
        end

        if asp_net_package.nil?
          dotnet_package = packages.find { |package| package[:name] == ".NET" }
          asp_net_package = { name: "ASP.NET", requirement: dotnet_package[:requirement], type: "runtime" } unless dotnet_package.nil?
        end

        asp_net_package
      end
    end
  end
end
