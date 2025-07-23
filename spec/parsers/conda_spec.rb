# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Conda do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("conda")
  end

  it "parses dependencies from environment.yml" do
    expect(described_class.analyse_contents("environment.yml", load_fixture("environment.yml"))).to eq(
      {
        platform: "conda",
        path: "environment.yml",
        dependencies: [
          Bibliothecary::Dependency.new(platform: "conda", name: "beautifulsoup4", requirement: "4.7.1", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "biopython", requirement: "1.74", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "certifi", requirement: "2019.6.16", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "ncurses", requirement: "6.1", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "numpy", requirement: "1.16.4", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "openssl", requirement: "1.1.1c", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "pip", requirement: "", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "python", requirement: "3.7.3", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "readline", requirement: "7.0", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "setuptools", requirement: "", type: "runtime", source: "environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "sqlite", requirement: "3.29.0", type: "runtime", source: "environment.yml"),
        ],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "parses dependencies from environment.yml ignoring pip" do
    expect(described_class.analyse_contents("conda_with_pip/environment.yml", load_fixture("conda_with_pip/environment.yml"))).to eq(
      {
        platform: "conda",
        path: "conda_with_pip/environment.yml",
        dependencies: [
          Bibliothecary::Dependency.new(platform: "conda", name: "pip", requirement: "", type: "runtime", source: "conda_with_pip/environment.yml"),
          Bibliothecary::Dependency.new(platform: "conda", name: "sqlite", requirement: "3.29.0", type: "runtime", source: "conda_with_pip/environment.yml"),
        ],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("environment.yml")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("test/foo/aenvironment.yml")).to be_falsey
  end

  describe "matchspecs" do
    it "parses name and requirements" do
      examples = [
        ["nltk=3.0.0=np18py27_0", "nltk", "3.0.0"],
        ["nltk=3.0.0", "nltk", "3.0.0"],
        ["nltk==3.0.0=np18py27_0", "nltk", "3.0.0"],
        ["nltk==3.0.0", "nltk", "3.0.0"],
        ["nltk", "nltk", ""],
        ["yaml>=3.0=py27_0", "yaml", ">=3.0"],
        ["yaml>=3.0", "yaml", ">=3.0"],
        ["numpy 1.8", "numpy", "1.8"],
        ["numpy 1.8*", "numpy", "1.8*"],
        ["numpy >=1.8,<2", "numpy", ">=1.8,<2"],
        ["numpy 1.8 ppy27_0", "numpy", "1.8"],
        ["numpy >=1.8,<2|1.9", "numpy", ">=1.8,<2|1.9"],
      ]

      examples.each do |ex|
        expect(described_class.parse_name_requirement_from_matchspec(ex[0])).to eq({ name: ex[1], requirement: ex[2] })
      end
    end
  end
end
