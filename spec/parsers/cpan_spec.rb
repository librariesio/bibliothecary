require 'spec_helper'

describe Bibliothecary::Parsers::CPAN do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('cpan')
  end

  it 'parses dependencies from META.yml' do
    expect(described_class.analyse_contents('META.yml', load_fixture('META.yml'))).to eq({
      :platform=>"cpan",
      :path=>"META.yml",
      :dependencies=>[
        {:name=>"Digest::MD5", :requirement=>0, :type=>"runtime"},
        {:name=>"File::Temp", :requirement=>0, :type=>"runtime"},
        {:name=>"LWP", :requirement=>0, :type=>"runtime"},
        {:name=>"XML::Simple", :requirement=>0, :type=>"runtime"},
        {:name=>"perl", :requirement=>"5.6.0", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from META.json' do
    expect(described_class.analyse_contents('META.json', load_fixture('META.json'))).to eq({
      :platform=>"cpan",
      :path=>"META.json",
      :dependencies=>[
        {:name=>"English", :requirement=>"1.00", :type=>"runtime"},
        {:name=>"Test::More", :requirement=>"0.45", :type=>"runtime"},
        {:name=>"Module::Build", :requirement=>"0.28", :type=>"runtime"},
        {:name=>"Getopt::Long", :requirement=>"2.32", :type=>"runtime"},
        {:name=>"List::Util", :requirement=>"1.07_00", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('META.yml')).to be_truthy
    expect(described_class.match?('META.json')).to be_truthy
  end
end
