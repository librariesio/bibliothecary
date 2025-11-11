require 'spec_helper'

describe Bibliothecary::Parsers::BentoML do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('bentoml')
  end

  it 'parses dependencies from bentofile.yaml' do
    expect(described_class.analyse_contents('bentofile.yaml', load_fixture('bentofile.yaml'))).to eq({
      :platform=>"bentoml",
      :path=>"bentofile.yaml",
      :dependencies=>[
        Bibliothecary::Dependency.new(platform: "bentoml", name: "iris_clf", requirement: "latest", type: "runtime", source: "bentofile.yaml")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from bentofile.yaml with tags and dictionary format' do
    expect(described_class.analyse_contents('bentofile.yaml', load_fixture('bentofile-with-tags.yaml'))).to eq({
      :platform=>"bentoml",
      :path=>"bentofile.yaml",
      :dependencies=>[
        Bibliothecary::Dependency.new(platform: "bentoml", name: "iris_clf", requirement: "v1.0", type: "runtime", source: "bentofile.yaml"),
        Bibliothecary::Dependency.new(platform: "bentoml", name: "bert_model", requirement: "20230101", type: "runtime", source: "bentofile.yaml"),
        Bibliothecary::Dependency.new(platform: "bentoml", name: "resnet50", requirement: "production", type: "runtime", source: "bentofile.yaml")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('bentofile.yaml')).to be_truthy
    expect(described_class.match?('bentofile.yml')).to be_falsey
    expect(described_class.match?('Dockerfile')).to be_falsey
  end
end
