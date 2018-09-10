require 'spec_helper'

describe Bibliothecary::Parsers::Cargo do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('cargo')
  end

  it 'parses dependencies from Cargo.toml' do
    expect(described_class.analyse_contents('Cargo.toml', load_fixture('Cargo.toml'))).to eq({
      :platform=>"cargo",
      :path=>"Cargo.toml",
      :dependencies=>[
        {:name=>"rustc-serialize", :requirement=>"*", :type=>"runtime"},
        {:name=>"regex", :requirement=>"*", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Cargo.lock' do
    expect(described_class.analyse_contents('Cargo.lock', load_fixture('Cargo.lock'))).to eq({
      :platform=>"cargo",
      :path=>"Cargo.lock",
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
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Cargo.toml')).to be_truthy
    expect(described_class.match?('Cargo.lock')).to be_truthy
  end
end
