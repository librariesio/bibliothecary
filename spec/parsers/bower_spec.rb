require 'spec_helper'

describe Bibliothecary::Parsers::Bower do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Bower::PLATFORM_NAME).to eq('bower')
  end

  it 'parses dependencies from bower.json' do
    file = load_fixture('bower.json')

    expect(Bibliothecary::Parsers::Bower.parse('bower.json', file)).to eq([
      {:name=>"jquery", :requirement=>">= 1.9.1", :type=>"runtime"}
    ])
  end
end
