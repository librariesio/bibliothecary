require 'spec_helper'

describe Bibliothecary::Parsers::Pub do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('pub')
  end

  it 'parses dependencies from pubspec.yaml' do
    expect(described_class.analyse_contents('pubspec.yaml', load_fixture('pubspec.yaml'))).to eq({
      :platform=>"pub",
      :path=>"pubspec.yaml",
      :dependencies=>[
        {:name=>"analyzer", :requirement=>">=0.22.0 <0.25.0", :type=>"runtime"},
        {:name=>"args", :requirement=>">=0.12.0 <0.13.0", :type=>"runtime"},
        {:name=>"benchmark_harness", :requirement=>">=1.0.0 <2.0.0", :type=>"development"},
        {:name=>"guinness", :requirement=>">=0.1.9 <0.2.0", :type=>"development"}
      ],
      kind: 'manifest'
    })
  end

  it 'parses dependencies from pubspec.lock' do
    expect(described_class.analyse_contents('pubspec.lock', load_fixture('pubspec.lock'))).to eq({
      :platform=>"pub",
      :path=>"pubspec.lock",
      :dependencies=>[
        {:name=>"analyzer", :requirement=>"0.24.6", :type=>"runtime"},
        {:name=>"args", :requirement=>"0.12.2+6", :type=>"runtime"},
        {:name=>"barback", :requirement=>"0.15.2+7", :type=>"runtime"},
        {:name=>"which", :requirement=>"0.1.3", :type=>"runtime"}
      ],
      kind: 'lockfile'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('pubspec.yaml')).to be_truthy
    expect(described_class.match?('pubspec.lock')).to be_truthy
  end
end
