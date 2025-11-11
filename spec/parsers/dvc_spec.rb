require 'spec_helper'

describe Bibliothecary::Parsers::DVC do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('dvc')
  end

  it 'parses model dependencies from dvc.yaml' do
    result = described_class.analyse_contents('dvc.yaml', load_fixture('dvc.yaml'))

    expect(result[:platform]).to eq('dvc')
    expect(result[:path]).to eq('dvc.yaml')
    expect(result[:kind]).to eq('manifest')
    expect(result[:success]).to be_truthy

    # Should find models from both artifacts and stages
    expect(result[:dependencies].length).to eq(3)

    # Check artifacts
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(
        platform: "dvc",
        name: "models/resnet.pt",
        requirement: "1.0.0",
        type: "runtime",
        source: "dvc.yaml"
      )
    )

    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(
        platform: "dvc",
        name: "models/bert-sentiment.h5",
        requirement: "latest",
        type: "runtime",
        source: "dvc.yaml"
      )
    )

    # Check stage outputs
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(
        platform: "dvc",
        name: "models/model.pkl",
        requirement: "latest",
        type: "runtime",
        source: "dvc.yaml"
      )
    )
  end

  it 'returns empty dependencies for dvc.yaml without models' do
    expect(described_class.analyse_contents('dvc.yaml', load_fixture('dvc-no-models.yaml'))).to eq({
      :platform=>"dvc",
      :path=>"dvc.yaml",
      :dependencies=>[],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('dvc.yaml')).to be_truthy
    expect(described_class.match?('dvc.yml')).to be_falsey
    expect(described_class.match?('DVC.yaml')).to be_falsey
  end
end
