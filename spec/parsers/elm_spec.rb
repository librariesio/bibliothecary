require 'spec_helper'

describe Bibliothecary::Parsers::Elm do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('elm')
  end

  it 'parses dependencies from elm-package.json' do
    expect(described_class.analyse_contents('elm-package.json', load_fixture('elm-package.json'))).to eq({
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
    expect(described_class.analyse_contents('elm_dependencies.json', load_fixture('elm_dependencies.json'))).to eq({
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
    expect(described_class.analyse_contents('elm-stuff/exact-dependencies.json', load_fixture('exact-dependencies.json'))).to eq({
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

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('elm-package.json')).to be_truthy
    expect(described_class.match?('elm_dependencies.json')).to be_truthy
    expect(described_class.match?('elm-stuff/exact-dependencies.json')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('node_modules/foo/elm-stuff/exact-dependencies.json')).to be_falsey
    expect(described_class.match?('node_modules/foo/elm_dependencies.json')).to be_falsey
    expect(described_class.match?('node_modules/foo/elm-package.json')).to be_falsey
  end
end
