require 'spec_helper'

describe Bibliothecary::Parsers::CPAN do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::CPAN::platform_name).to eq('cpan')
  end

  it 'parses dependencies from META.yml' do
    file = load_fixture('META.yml')

    expect(Bibliothecary::Parsers::CPAN.analyse_file('META.yml', file, 'META.yml')).to eq({
      :platform=>"cpan",
      :path=>"META.yml",
      :dependencies=>[
        {:name=>"Digest::MD5", :requirement=>0, :type=>"runtime"},
        {:name=>"File::Temp", :requirement=>0, :type=>"runtime"},
        {:name=>"LWP", :requirement=>0, :type=>"runtime"},
        {:name=>"XML::Simple", :requirement=>0, :type=>"runtime"},
        {:name=>"perl", :requirement=>"5.6.0", :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from META.json' do
    file = load_fixture('META.json')

    expect(Bibliothecary::Parsers::CPAN.analyse_file('META.json', file, 'META.json')).to eq({
      :platform=>"cpan",
      :path=>"META.json",
      :dependencies=>[
        {:name=>"English", :requirement=>"1.00", :type=>"runtime"},
        {:name=>"Test::More", :requirement=>"0.45", :type=>"runtime"},
        {:name=>"Module::Build", :requirement=>"0.28", :type=>"runtime"},
        {:name=>"Getopt::Long", :requirement=>"2.32", :type=>"runtime"},
        {:name=>"List::Util", :requirement=>"1.07_00", :type=>"runtime"}
      ]
    })
  end
end
