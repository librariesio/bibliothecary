require 'spec_helper'

describe Bibliothecary::Parsers::Cargo do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Cargo::platform_name).to eq('cargo')
  end

  it 'parses dependencies from Cargo.toml' do
    expect(Bibliothecary::Parsers::Cargo.analyse_file('Cargo.toml', fixture_path('Cargo.toml'))).to eq({
      :platform=>"cargo",
      :path=>"spec/fixtures/Cargo.toml",
      :dependencies=>[
        {:name=>"rustc-serialize", :requirement=>"*", :type=>"runtime"},
        {:name=>"regex", :requirement=>"*", :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from Cargo.lock' do
    expect(Bibliothecary::Parsers::Cargo.analyse_file('Cargo.lock', fixture_path('Cargo.lock'))).to eq({
      :platform=>"cargo",
      :path=>"spec/fixtures/Cargo.lock",
      :dependencies=>[
        {:name=>"advapi32-sys", :requirement=>"0.1.2", :type=>"runtime"},
        {:name=>"aho-corasick", :requirement=>"0.4.0", :type=>"runtime"},
        {:name=>"byteorder", :requirement=>"0.4.2", :type=>"runtime"},
        {:name=>"chrono", :requirement=>"0.2.17", :type=>"runtime"},
        {:name=>"docopt", :requirement=>"0.6.78", :type=>"runtime"},
        {:name=>"gcc", :requirement=>"0.3.21", :type=>"runtime"},
        {:name=>"hashindexed", :requirement=>"0.1.0", :type=>"runtime"},
        {:name=>"kernel32-sys", :requirement=>"0.2.1", :type=>"runtime"},
        {:name=>"libc", :requirement=>"0.1.12", :type=>"runtime"},
        {:name=>"libc", :requirement=>"0.2.4", :type=>"runtime"}
      ]
    })
  end
end
