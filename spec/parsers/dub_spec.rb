require 'spec_helper'

describe Bibliothecary::Parsers::Dub do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('dub')
  end

  it 'parses dependencies from dub.json' do
    expect(described_class.analyse_contents('dub.json', load_fixture('dub.json'))).to eq({
      :platform=>"dub",
      :path=>"dub.json",
      :dependencies=>[
        {:name=>"vibe-d", :requirement=>"~>0.7.22", :type=>"runtime"},
        {:name=>"libdparse",
         :requirement=>{"optional"=>true, "version"=>"~>0.2.0"},
         :type=>"runtime"}
      ],
      kind: 'manifest'
    })
  end

  it 'parses dependencies from dub.sdl' do
    expect(described_class.analyse_contents('dub.sdl', load_fixture('dub.sdl'))).to eq({
      :platform=>"dub",
      :path=>"dub.sdl",
      :dependencies=>[
        {:name=>"vibe-d", :requirement=>"~>0.7.23", :type=>:runtime}
      ],
      kind: 'manifest'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('dub.json')).to be_truthy
    expect(described_class.match?('dub.sdl')).to be_truthy
  end
end
