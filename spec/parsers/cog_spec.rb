require 'spec_helper'

describe Bibliothecary::Parsers::Cog do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('cog')
  end

  it 'parses dependencies from cog.yaml' do
    result = described_class.analyse_contents('cog.yaml', load_fixture('cog.yaml'))

    expect(result[:platform]).to eq('cog')
    expect(result[:path]).to eq('cog.yaml')
    expect(result[:kind]).to eq('manifest')
    expect(result[:success]).to be_truthy

    expect(result[:dependencies].length).to eq(5)

    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(
        platform: "cog",
        name: "torch",
        requirement: "2.0.1",
        type: "runtime",
        source: "cog.yaml"
      )
    )

    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(
        platform: "cog",
        name: "transformers",
        requirement: "4.30.0",
        type: "runtime",
        source: "cog.yaml"
      )
    )

    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(
        platform: "cog",
        name: "diffusers",
        requirement: "*",
        type: "runtime",
        source: "cog.yaml"
      )
    )
  end

  it 'returns empty dependencies for cog.yaml with python_requirements' do
    expect(described_class.analyse_contents('cog.yaml', load_fixture('cog-requirements.yaml'))).to eq({
      :platform=>"cog",
      :path=>"cog.yaml",
      :dependencies=>[],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'returns empty dependencies for cog.yaml without python_packages' do
    expect(described_class.analyse_contents('cog.yaml', load_fixture('cog-no-deps.yaml'))).to eq({
      :platform=>"cog",
      :path=>"cog.yaml",
      :dependencies=>[],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('cog.yaml')).to be_truthy
    expect(described_class.match?('cog.yml')).to be_falsey
    expect(described_class.match?('Cog.yaml')).to be_falsey
  end
end
