require "spec_helper"

describe Bibliothecary::Parsers::Hackage do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("hackage")
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("cabal-parser.cabal")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("cabal.nix")).to be_falsey
    expect(described_class.match?("cabal-parser.nix")).to be_falsey
    expect(described_class.match?("cabal.sandbox.config")).to be_falsey
    expect(described_class.match?("ChangeLog.md")).to be_falsey
    expect(described_class.match?("CODE_OF_CONDUCT.md")).to be_falsey
    expect(described_class.match?("default.nix")).to be_falsey
    expect(described_class.match?("dist")).to be_falsey
    expect(described_class.match?("docker-compose.yml")).to be_falsey
    expect(described_class.match?("Dockerfile")).to be_falsey
    expect(described_class.match?("LICENSE")).to be_falsey
    expect(described_class.match?("README.md")).to be_falsey
    expect(described_class.match?("Setup.hs")).to be_falsey
    expect(described_class.match?("shell.nix")).to be_falsey
    expect(described_class.match?("src")).to be_falsey
    expect(described_class.match?("test")).to be_falsey
  end

  it 'parses dependencies from *.cabal files' do
    expect(described_class.analyse_contents('example.cabal', load_fixture('example.cabal'))).to eq({
      :platform=>"hackage",
      :path=>"example.cabal",
      :dependencies=>[
        {:requirement=>"==1.1.*", :name=>"aeson", :type=>"runtime"},
        {:requirement=>">=4.9 && <4.11", :name=>"base", :type=>"runtime"},
        {:requirement=>"==2.0.*", :name=>"Cabal", :type=>"runtime"},
        {:requirement=>"==1.3.*", :name=>"envy", :type=>"runtime"},
        {:requirement=>"==1.1.*", :name=>"pretty", :type=>"runtime"},
        {:requirement=>"==0.11.*", :name=>"servant-server", :type=>"runtime"},
        {:requirement=>"==1.2.*", :name=>"text", :type=>"runtime"},
        {:requirement=>"==1.0.*", :name=>"utf8-string", :type=>"runtime"},
        {:requirement=>"==3.2.*", :name=>"warp", :type=>"runtime"},
        {:requirement=>"==2.4.*", :name=>"hspec-discover", :type=>"build"},
        {:requirement=>"==1.1.*", :name=>"aeson", :type=>"test"},
        {:requirement=>">=4.9 && <4.11", :name=>"base", :type=>"test"},
        {:requirement=>"==0.10.*", :name=>"bytestring", :type=>"test"},
        {:requirement=>"==2.0.*", :name=>"Cabal", :type=>"test"},
        {:requirement=>"==2.4.*", :name=>"hspec", :type=>"test"},
        {:requirement=>"==1.1.*", :name=>"pretty", :type=>"test"},
        {:requirement=>"==1.2.*", :name=>"text", :type=>"test"}
      ],
      kind: 'manifest'
    })
  end


end
