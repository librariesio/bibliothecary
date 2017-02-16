require 'spec_helper'

describe Bibliothecary::Parsers::Hex do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('hex')
  end

  it 'parses dependencies from mix.exs' do
    expect(described_class.analyse_file('mix.exs', fixture_path('mix.exs'))).to eq({
      :platform=>"hex",
      :path=>"spec/fixtures/mix.exs",
      :dependencies=>[
        {:name=>"poison", :version=>"~> 1.3.1", :type=>"runtime"},
        {:name=>"plug", :version=>"~> 0.11.0", :type=>"runtime"},
        {:name=>"cowboy", :version=>"~> 1.0.0", :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from mix.lock' do
    expect(described_class.analyse_file('mix.lock', fixture_path('mix.lock'))).to eq({
      :platform=>"hex",
      :path=>"spec/fixtures/mix.lock",
      :dependencies=>[
        {:name=>"ranch", :version=>"1.2.1", :type=>"runtime"},
        {:name=>"poison", :version=>"2.1.0", :type=>"runtime"},
        {:name=>"plug", :version=>"1.1.6", :type=>"runtime"},
        {:name=>"cowlib", :version=>"1.0.2", :type=>"runtime"},
        {:name=>"cowboy", :version=>"1.0.4", :type=>"runtime"}
      ]
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('mix.exs')).to be_truthy
    expect(described_class.match?('mix.lock')).to be_truthy
  end
end
