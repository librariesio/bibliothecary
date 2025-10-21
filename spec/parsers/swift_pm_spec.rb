require "spec_helper"

describe Bibliothecary::Parsers::SwiftPM do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("swiftpm")
  end

  it "parses dependencies from Package.swift", :vcr do
    stub_request(:post, "http://swift.libraries.io/to-json").
      with(
        body: load_fixture("Package.swift"),
        headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate({
        "dependencies" => [
          {"url" => "https://github.com/qutheory/vapor.git", "version" => {"lowerBound" => "0.12.0", "upperBound" => "0.12.9223372036854775807"}},
          {"url" => "https://github.com/czechboy0/Tasks.git", "version" => {"lowerBound" => "0.2.0", "upperBound" => "0.2.9223372036854775807"}},
          {"url" => "https://github.com/czechboy0/Environment.git", "version" => {"lowerBound" => "0.4.0", "upperBound" => "0.4.9223372036854775807"}}
        ]
      }), headers: {})

    expect(described_class.analyse_contents("Package.swift", load_fixture("Package.swift"))).to eq({
      platform: "swiftpm",
      path: "Package.swift",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "swiftpm", name: "github.com/qutheory/vapor", requirement: "0.12.0 - 0.12.9223372036854775807", type: "runtime", source: "Package.swift"),
        Bibliothecary::Dependency.new(platform: "swiftpm", name: "github.com/czechboy0/Tasks", requirement: "0.2.0 - 0.2.9223372036854775807", type: "runtime", source: "Package.swift"),
        Bibliothecary::Dependency.new(platform: "swiftpm", name: "github.com/czechboy0/Environment", requirement: "0.4.0 - 0.4.9223372036854775807", type: "runtime", source: "Package.swift"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it 'parses dependencies from Package.resolved' do
    expect(described_class.analyse_contents('Package.resolved', load_fixture('Package.resolved'))).to eq({
      platform: "swiftpm",
      path: "Package.resolved",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "swiftpm", name: "github.com/jpsim/Yams", requirement: "5.0.1", type: "runtime", source: "Package.resolved"),
      ],
      kind: 'lockfile',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from Package.resolved in version 2 format' do
    expect(described_class.analyse_contents('Package.resolved', load_fixture('Package.resolved.2'))).to eq({
      platform: "swiftpm",
      path: "Package.resolved",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "swiftpm", name: "github.com/krzyzanowskim/CryptoSwift", requirement: "1.6.0", type: "runtime", source: "Package.resolved"),
        Bibliothecary::Dependency.new(platform: "swiftpm", name: "github.com/apple/swift-docc-plugin", requirement: "1.0.0", type: "runtime", source: "Package.resolved")
      ],
      kind: 'lockfile',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Package.swift')).to be_truthy
    expect(described_class.match?('Package.resolved')).to be_truthy
  end
end
