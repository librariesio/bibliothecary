require 'spec_helper'

describe Bibliothecary::Parsers::SwiftPM do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('swiftpm')
  end

  it 'parses dependencies from Package.swift', :vcr do
    expect(described_class.analyse_contents('Package.swift', load_fixture('Package.swift'))).to eq({
      platform: "swiftpm",
      path: "Package.swift",
      dependencies: [
        { name: "github.com/qutheory/vapor", requirement: "0.12.0 - 0.12.9223372036854775807", type: "runtime" },
        { name: "github.com/czechboy0/Tasks", requirement: "0.2.0 - 0.2.9223372036854775807", type: "runtime" },
        { name: "github.com/czechboy0/Environment", requirement: "0.4.0 - 0.4.9223372036854775807", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Package.resolved' do
    expect(described_class.analyse_contents('Package.resolved', load_fixture('Package.resolved'))).to eq({
      platform: "swiftpm",
      path: "Package.resolved",
      dependencies: [
        { name: "github.com/jpsim/Yams", requirement: "5.0.1", type: "runtime" },
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from Package.resolved in version 2 format' do
    expect(described_class.analyse_contents('Package.resolved', load_fixture('Package.resolved.2'))).to eq({
      platform: "swiftpm",
      path: "Package.resolved",
      dependencies: [
        {:name=>"github.com/krzyzanowskim/CryptoSwift", :requirement=>"1.6.0", :type=>"runtime"},
        {:name=>"github.com/apple/swift-docc-plugin", :requirement=>"1.0.0", :type=>"runtime"}
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Package.swift')).to be_truthy
    expect(described_class.match?('Package.resolved')).to be_truthy
  end
end
