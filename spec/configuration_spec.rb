require 'spec_helper'

describe Bibliothecary::Configuration do
  let(:config) { described_class.new }

  it 'should have a default list of ignored dirs' do
    expect(config.ignored_dirs).to eq(['.git', 'node_modules', 'bower_components', 'fixtures', 'vendor', 'dist'])
  end

  it 'should have a default host for carthage parser' do
    expect(config.carthage_parser_host).to eq('https://carthage.libraries.io')
  end

  it 'should have a default host for clojars parser' do
    expect(config.clojars_parser_host).to eq('https://clojars.libraries.io')
  end

  it 'should have a default host for mix parser' do
    expect(config.mix_parser_host).to eq('https://mix.libraries.io')
  end

  it 'should have a default host for gradle parser' do
    expect(config.gradle_parser_host).to eq('https://gradle-parser.libraries.io')
  end

  it 'should have a default host for yarn parser' do
    expect(config.yarn_parser_host).to eq('https://yarn-parser.libraries.io')
  end

  it 'should have a default host for swift parser' do
    expect(config.swift_parser_host).to eq('http://swift.libraries.io')
  end

  it 'should have a default host for swift parser' do
    expect(config.cabal_parser_host).to eq('http://cabal.libraries.io')
  end
end
