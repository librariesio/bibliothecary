require 'spec_helper'

describe Bibliothecary::Parsers::Clojars do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('clojars')
  end

  it 'parses dependencies from project.clj' do
    expect(described_class.analyse_contents('project.clj', load_fixture('project.clj'))).to eq({
      :platform=>"clojars",
      :path=>"project.clj",
      :dependencies=>[
        {:name=>"org.clojure/clojure", :version=>"1.6.0", :type=>"runtime"},
        {:name=>"cheshire", :version=>"5.4.0", :type=>"runtime"},
        {:name=>"compojure", :version=>"1.3.2", :type=>"runtime"},
        {:name=>"ring/ring-defaults", :version=>"0.1.2", :type=>"runtime"},
        {:name=>"ring/ring-jetty-adapter", :version=>"1.2.1", :type=>"runtime"}
      ],
      kind: 'manifest'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('project.clj')).to be_truthy
  end
end
