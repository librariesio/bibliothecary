require "spec_helper"

describe Bibliothecary::Parsers::Haskell do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("haskell")
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
end
