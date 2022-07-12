require 'spec_helper'

describe Bibliothecary::Parsers::Carthage do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('carthage')
  end

  it 'parses dependencies from Cartfile', :vcr do
    expect(described_class.analyse_contents('Cartfile', load_fixture('Cartfile'))).to eq({
      platform: "carthage",
      path: "Cartfile",
      dependencies: [
         { name: "ReactiveCocoa/ReactiveCocoa", requirement: ">= 2.3.1", type: "runtime" },
         { name: "Mantle/Mantle", requirement: "~> 1.0", type: "runtime" },
         { name: "jspahrsummers/libextobjc", requirement: "== 0.4.1", type: "runtime" },
         { name: "jspahrsummers/xcconfigs", requirement: " ", type: "runtime" },
         { name: "jspahrsummers/xcconfigs", requirement: "branch ", type: "runtime" },
         { name: "https://enterprise.local/ghe/desktop/git-error-translations",requirement: " ",type: "runtime" },
         { name: "https://enterprise.local/desktop/git-error-translations2.git",requirement: "development ",type: "runtime" },
         { name: "file:///directory/to/project", requirement: "branch ", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Cartfile.private', :vcr do
    expect(described_class.analyse_contents('Cartfile.private', load_fixture('Cartfile.private'))).to eq({
      platform: "carthage",
      path: "Cartfile.private",
      dependencies: [
        { name: "Quick/Quick", requirement: "~> 0.9", type: "development" },
        { name: "Quick/Nimble", requirement: "~> 3.1", type: "development" },
        { name: "jspahrsummers/xcconfigs",requirement: "ec5753493605deed7358dec5f9260f503d3ed650 ",type: "development" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Cartfile.resolved', :vcr do
    expect(described_class.analyse_contents('Cartfile.resolved', load_fixture('Cartfile.resolved'))).to eq({
      platform: "carthage",
      path: "Cartfile.resolved",
      dependencies: [
        { name: "thoughtbot/Argo", requirement: "v2.2.0 ", type: "runtime" },
        { name: "Quick/Nimble", requirement: "v3.1.0 ", type: "runtime" },
        { name: "jdhealy/PrettyColors", requirement: "v3.0.0 ", type: "runtime" },
        { name: "Quick/Quick", requirement: "v0.9.1 ", type: "runtime" },
        { name: "antitypical/Result", requirement: "1.0.2 ", type: "runtime" },
        { name: "jspahrsummers/xcconfigs",requirement: "ec5753493605deed7358dec5f9260f503d3ed650 ",type: "runtime" },
        { name: "Carthage/Commandant", requirement: "0.8.3 ", type: "runtime" },
        { name: "ReactiveCocoa/ReactiveCocoa", requirement: "v4.0.1 ", type: "runtime" },
        { name: "Carthage/ReactiveTask", requirement: "0.9.1 ", type: "runtime" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Cartfile')).to be_truthy
    expect(described_class.match?('Cartfile.private')).to be_truthy
    expect(described_class.match?('Cartfile.resolved')).to be_truthy
  end
end
