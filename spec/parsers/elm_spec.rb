require 'spec_helper'

describe Bibliothecary::Parsers::Elm do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Elm::PLATFORM_NAME).to eq('elm')
  end

  it 'parses dependencies from elm-package.json' do
    file = load_fixture('elm-package.json')

    expect(Bibliothecary::Parsers::Elm.parse('elm-package.json', file)).to eq([
      {:name=>"evancz/elm-markdown",
       :requirement=>"1.1.0 <= v < 2.0.0",
       :type=>"runtime"},
      {:name=>"evancz/elm-html",
       :requirement=>"1.0.0 <= v < 2.0.0",
       :type=>"runtime"},
      {:name=>"evancz/local-channel",
       :requirement=>"1.0.0 <= v < 2.0.0",
       :type=>"runtime"},
      {:name=>"elm-lang/core",
       :requirement=>"1.0.0 <= v < 2.0.0",
       :type=>"runtime"}])
  end

  it 'parses dependencies from elm_dependencies.json' do
    file = load_fixture('elm_dependencies.json')

    expect(Bibliothecary::Parsers::Elm.parse('elm_dependencies.json', file)).to eq([
      {:name=>"johnpmayer/elm-webgl", :requirement=>"0.1.1", :type=>"runtime"},
      {:name=>"johnpmayer/elm-linear-algebra",
       :requirement=>"1.0.1",
       :type=>"runtime"}])
  end

  it 'parses dependencies from elm-stuff/exact-dependencies.json' do
    file = load_fixture('exact-dependencies.json')

    expect(Bibliothecary::Parsers::Elm.parse('elm-stuff/exact-dependencies.json', file)).to eq([
      {:name=>"jvoigtlaender/elm-drag-and-drop",
       :requirement=>"1.0.1",
       :type=>"runtime"},
      {:name=>"evancz/elm-html", :requirement=>"2.0.0", :type=>"runtime"},
      {:name=>"elm-lang/core", :requirement=>"1.1.1", :type=>"runtime"},
      {:name=>"evancz/automaton", :requirement=>"1.0.0", :type=>"runtime"},
      {:name=>"evancz/virtual-dom", :requirement=>"1.2.2", :type=>"runtime"}])
  end
end
