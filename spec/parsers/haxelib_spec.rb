require 'spec_helper'

describe Bibliothecary::Parsers::Haxelib do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('haxelib')
  end

  it 'parses dependencies from bower.json' do
    expect(described_class.analyse_contents('haxelib.json', load_fixture('haxelib.json'))).to eq({
      :platform=>"haxelib",
      :path=>"haxelib.json",
      :dependencies=>[
        {:name=>"lime", :requirement=>"2.9.1", :type=>"runtime"},
        {:name=>"openfl", :requirement=>"3.6.1", :type=>"runtime"}
      ],
      kind: 'manifest'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('haxelib.json')).to be_truthy
  end
end
