require 'spec_helper'

describe Bibliothecary::Parsers::Clojars do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Clojars::PLATFORM_NAME).to eq('clojars')
  end

  it 'parses dependencies from project.clj' do
    file = load_fixture('project.clj')

    expect(Bibliothecary::Parsers::Clojars.parse('project.clj', file)).to eq([
      {:name=>"org.clojure/clojure", :version=>"1.6.0", :type=>"runtime"},
      {:name=>"cheshire", :version=>"5.4.0", :type=>"runtime"},
      {:name=>"compojure", :version=>"1.3.2", :type=>"runtime"},
      {:name=>"ring/ring-defaults", :version=>"0.1.2", :type=>"runtime"},
      {:name=>"ring/ring-jetty-adapter", :version=>"1.2.1", :type=>"runtime"}
    ])
  end
end
