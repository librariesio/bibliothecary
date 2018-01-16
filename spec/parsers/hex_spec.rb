require 'spec_helper'

describe Bibliothecary::Parsers::Hex do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('hex')
  end

  it 'parses dependencies from mix.exs' do
    expect(described_class.analyse_contents('mix.exs', load_fixture('mix.exs'))).to eq({
      :platform=>"hex",
      :path=>"mix.exs",
      :dependencies=>[
        {:name=>"poison", :requirement=>"~> 1.3.1", :type=>"runtime"},
        {:name=>"plug", :requirement=>"~> 0.11.0", :type=>"runtime"},
        {:name=>"cowboy", :requirement=>"~> 1.0.0", :type=>"runtime"}
      ],
      kind: 'manifest'
    })
  end

  it 'parses dependencies from mix.lock' do
    expect(described_class.analyse_contents('mix.lock', load_fixture('mix.lock'))).to eq({
      :platform=>"hex",
      :path=>"mix.lock",
      :dependencies=>[
        {:name=>"ranch", :requirement=>"1.2.1", :type=>"runtime"},
        {:name=>"poison", :requirement=>"2.1.0", :type=>"runtime"},
        {:name=>"plug", :requirement=>"1.1.6", :type=>"runtime"},
        {:name=>"cowlib", :requirement=>"1.0.2", :type=>"runtime"},
        {:name=>"cowboy", :requirement=>"1.0.4", :type=>"runtime"}
      ],
      kind: 'lockfile'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('mix.exs')).to be_truthy
    expect(described_class.match?('mix.lock')).to be_truthy
  end
end
