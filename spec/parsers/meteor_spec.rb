require 'spec_helper'

describe Bibliothecary::Parsers::Meteor do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('meteor')
  end

  it 'parses dependencies from versions.json' do
    expect(described_class.analyse_contents('versions.json', load_fixture('versions.json'))).to eq({
      platform: "meteor",
      path: "versions.json",
      dependencies: [
        { name: "accounts-base", requirement: "1.1.2", type: "runtime" },
        { name: "application-configuration", requirement: "1.0.3", type: "runtime" },
        { name: "base64", requirement: "1.0.1", type: "runtime" },
        { name: "binary-heap", requirement: "1.0.1", type: "runtime" },
        { name: "tracker", requirement: "1.0.3", type: "runtime" },
        { name: "underscore", requirement: "1.0.1", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('versions.json')).to be_truthy
  end
end
