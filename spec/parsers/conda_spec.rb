require 'spec_helper'

describe Bibliothecary::Parsers::Conda do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('conda')
  end

  it 'parses dependencies from environment.yml' do
    expect(described_class.analyse_contents('environment.yml', load_fixture('environment.yml'))).to eq({
      :platform=>"conda",
      :path=>"environment.yml",
      :dependencies=>[
        {:name=>"beautifulsoup4", :requirement=>"4.7.1", :type=>"runtime"},
        {:name=>"biopython", :requirement=>"1.74", :type=>"runtime"},
        {:name=>"certifi", :requirement=>"2019.6.16", :type=>"runtime"},
        {:name=>"ncurses", :requirement=>"6.1", :type=>"runtime"},
        {:name=>"numpy", :requirement=>"1.16.4", :type=>"runtime"},
        {:name=>"openssl", :requirement=>"1.1.1c", :type=>"runtime"},
        {:name=>"pip", :requirement=>">= 0", :type=>"runtime"},
        {:name=>"python", :requirement=>"3.7.3", :type=>"runtime"},
        {:name=>"readline", :requirement=>"7.0", :type=>"runtime"},
        {:name=>"setuptools", :requirement=>">= 0", :type=>"runtime"},
        {:name=>"sqlite", :requirement=>"3.29.0", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('environment.yml')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('test/foo/aenvironment.yml')).to be_falsey
  end
end
