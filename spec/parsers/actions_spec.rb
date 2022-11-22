require 'spec_helper'

describe Bibliothecary::Parsers::Actions do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('actions')
  end

  it 'parses dependencies from node actions.yml' do
    expect(described_class.analyse_contents('action.yml', load_fixture('action.yml'))).to eq({
      platform: "actions",
      path: "action.yml",
      dependencies: [{:name=>"dist/index.js", :requirement=>"node16", :type=>"javascript"}],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from docker actions.yml' do
    expect(described_class.analyse_contents('action.yml', load_fixture('docker-action.yml'))).to eq({
      platform: "actions",
      path: "action.yml",
      dependencies: [
        {:name=>"Dockerfile", :requirement=>"*", :type=>"docker"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from composite actions.yml' do
    expect(described_class.analyse_contents('action.yml', load_fixture('composite-action.yml'))).to eq({
      platform: "actions",
      path: "action.yml",
      dependencies: [
        {:name=>"aws-actions/configure-aws-credentials", :requirement=>"v1", :type=>"composite"},
        {:name=>"actions/setup-node", :requirement=>"v2", :type=>"composite"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('action.yml')).to be_truthy
    expect(described_class.match?('action.yaml')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('test/foo/aaction.yml')).to be_falsey
  end
end
