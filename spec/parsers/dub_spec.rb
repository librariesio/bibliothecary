require 'spec_helper'

describe Bibliothecary::Parsers::Dub do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('dub')
  end

  it 'parses dependencies from dub.json' do
    expect(described_class.analyse_file('dub.json', fixture_path('dub.json'))).to eq({
      :platform=>"dub",
      :path=>"spec/fixtures/dub.json",
      :dependencies=>[
        {:name=>"vibe-d", :requirement=>"~>0.7.22", :type=>"runtime"},
        {:name=>"libdparse",
         :requirement=>{"optional"=>true, "version"=>"~>0.2.0"},
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from dub.sdl' do
    expect(described_class.analyse_file('dub.sdl', fixture_path('dub.sdl'))).to eq({
      :platform=>"dub",
      :path=>"spec/fixtures/dub.sdl",
      :dependencies=>[
        {:name=>"vibe-d", :version=>"~>0.7.23", :type=>:runtime}
      ]
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('dub.json')).to be_truthy
    expect(described_class.match?('dub.sdl')).to be_truthy
  end
end
