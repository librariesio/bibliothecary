require 'spec_helper'

describe Bibliothecary::Parsers::Docker do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('docker')
  end

  it 'parses dependencies from docker-compose.yml' do
    expect(described_class.analyse_contents('docker-compose.yml', load_fixture('docker-compose.yml'))).to eq({
      :platform=>"docker",
      :path=>"docker-compose.yml",
      :dependencies=>[
        {:name=>"postgres", :requirement=>"9.6-alpine", :type=>"runtime"},
        {:name=>"redis", :requirement=>"4.0-alpine", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Dockerfile' do
    expect(described_class.analyse_contents('Dockerfile', load_fixture('Dockerfile'))).to eq({
      :platform=>"docker",
      :path=>"Dockerfile",
      :dependencies=>[
        {:name=>"ruby", :requirement=>"3.1.2-alpine", :type=>"build"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Dockerfile')).to be_truthy
    expect(described_class.match?('docker-compose.yml')).to be_truthy
    expect(described_class.match?('docker-compose-dev.yml')).to be_truthy
    expect(described_class.match?('docker-compose.prod.yml')).to be_truthy
  end
end
