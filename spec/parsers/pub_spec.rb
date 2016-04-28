require 'spec_helper'

describe Bibliothecary::Parsers::Pub do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Pub::PLATFORM_NAME).to eq('Pub')
  end

  it 'parses dependencies from pubspec.yaml' do
    file = load_fixture('pubspec.yaml')

    expect(Bibliothecary::Parsers::Pub.parse('pubspec.yaml', file)).to eq([
      {:name=>"analyzer", :requirement=>">=0.22.0 <0.25.0", :type=>"runtime"},
      {:name=>"args", :requirement=>">=0.12.0 <0.13.0", :type=>"runtime"},
      {:name=>"benchmark_harness", :requirement=>">=1.0.0 <2.0.0", :type=>"development"},
      {:name=>"guinness", :requirement=>">=0.1.9 <0.2.0", :type=>"development"}
    ])
  end

  it 'parses dependencies from pubspec.lock' do
    file = load_fixture('pubspec.lock')

    expect(Bibliothecary::Parsers::Pub.parse('pubspec.lock', file)).to eq([
      {:name=>"analyzer", :requirement=>"0.24.6", :type=>"runtime"},
      {:name=>"args", :requirement=>"0.12.2+6", :type=>"runtime"},
      {:name=>"barback", :requirement=>"0.15.2+7", :type=>"runtime"},
      {:name=>"which", :requirement=>"0.1.3", :type=>"runtime"}
    ])
  end
end
