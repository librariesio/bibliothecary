require 'spec_helper'

describe Bibliothecary::Parsers::MLflow do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('mlflow')
  end

  it 'parses dependencies from MLmodel with HuggingFace reference' do
    expect(described_class.analyse_contents('MLmodel', load_fixture('MLmodel'))).to eq({
      :platform=>"mlflow",
      :path=>"MLmodel",
      :dependencies=>[
        Bibliothecary::Dependency.new(
          platform: "mlflow",
          name: "meta-llama/Meta-Llama-3.1-70B-Instruct",
          requirement: "33101ce6ccc08fa6249c10a543ebfcac65173393",
          type: "runtime",
          source: "MLmodel"
        )
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'returns empty dependencies for MLmodel without source model references' do
    expect(described_class.analyse_contents('MLmodel', load_fixture('MLmodel-no-source'))).to eq({
      :platform=>"mlflow",
      :path=>"MLmodel",
      :dependencies=>[],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('MLmodel')).to be_truthy
    expect(described_class.match?('mlmodel')).to be_falsey
    expect(described_class.match?('MLmodel.yaml')).to be_falsey
  end
end
