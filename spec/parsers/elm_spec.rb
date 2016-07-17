require 'spec_helper'

describe Bibliothecary::Parsers::Elm do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Elm::platform_name).to eq('elm')
  end

  it 'parses dependencies from elm-package.json' do
    file = load_fixture('elm-package.json')

    expect(Bibliothecary::Parsers::Elm.analyse_file('elm-package.json', file, 'elm-package.json')).to eq({
      :platform=>"elm",
      :path=>"elm-package.json",
      :dependencies=>[
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
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from elm_dependencies.json' do
    file = load_fixture('elm_dependencies.json')

    expect(Bibliothecary::Parsers::Elm.analyse_file('elm_dependencies.json', file, 'elm_dependencies.json')).to eq({
      :platform=>"elm",
      :path=>"elm_dependencies.json",
      :dependencies=>[
        {:name=>"johnpmayer/elm-webgl", :requirement=>"0.1.1", :type=>"runtime"},
        {:name=>"johnpmayer/elm-linear-algebra",
         :requirement=>"1.0.1",
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from elm-stuff/exact-dependencies.json' do
    file = load_fixture('exact-dependencies.json')

    expect(Bibliothecary::Parsers::Elm.analyse_file('elm-stuff/exact-dependencies.json', file, 'elm-stuff/exact-dependencies.json')).to eq({
      :platform=>"elm",
      :path=>"elm-stuff/exact-dependencies.json",
      :dependencies=>[
        {:name=>"jvoigtlaender/elm-drag-and-drop",
         :requirement=>"1.0.1",
         :type=>"runtime"},
        {:name=>"evancz/elm-html", :requirement=>"2.0.0", :type=>"runtime"},
        {:name=>"elm-lang/core", :requirement=>"1.1.1", :type=>"runtime"},
        {:name=>"evancz/automaton", :requirement=>"1.0.0", :type=>"runtime"},
        {:name=>"evancz/virtual-dom", :requirement=>"1.2.2", :type=>"runtime"}
      ]
    })
  end
end
