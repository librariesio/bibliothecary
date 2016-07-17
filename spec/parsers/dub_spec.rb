require 'spec_helper'

describe Bibliothecary::Parsers::Dub do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Dub::platform_name).to eq('dub')
  end

  it 'parses dependencies from dub.json' do
    file = load_fixture('dub.json')

    expect(Bibliothecary::Parsers::Dub.analyse_file('dub.json', file, 'dub.json')).to eq({
      :platform=>"dub",
      :path=>"dub.json",
      :dependencies=>[
        {:name=>"vibe-d", :requirement=>"~>0.7.22", :type=>"runtime"},
        {:name=>"libdparse",
         :requirement=>{"optional"=>true, "version"=>"~>0.2.0"},
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from dub.sdl' do
    file = load_fixture('dub.sdl')

    expect(Bibliothecary::Parsers::Dub.analyse_file('dub.sdl', file, 'dub.sdl')).to eq({
      :platform=>"dub",
      :path=>"dub.sdl",
      :dependencies=>[
        {:name=>"vibe-d", :version=>"~>0.7.23", :type=>:runtime}
      ]
    })
  end
end
