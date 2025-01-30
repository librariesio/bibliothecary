require "spec_helper"

describe Bibliothecary::Parsers::Meteor do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("meteor")
  end

  it "parses dependencies from versions.json" do
    expect(described_class.analyse_contents("versions.json", load_fixture("versions.json"))).to eq({
      platform: "meteor",
      path: "versions.json",
      dependencies: [
        Bibliothecary::Dependency.new(name: "accounts-base", requirement: "1.1.2", type: "runtime", source: "versions.json"),
        Bibliothecary::Dependency.new(name: "application-configuration", requirement: "1.0.3", type: "runtime", source: "versions.json"),
        Bibliothecary::Dependency.new(name: "base64", requirement: "1.0.1", type: "runtime", source: "versions.json"),
        Bibliothecary::Dependency.new(name: "binary-heap", requirement: "1.0.1", type: "runtime", source: "versions.json"),
        Bibliothecary::Dependency.new(name: "tracker", requirement: "1.0.3", type: "runtime", source: "versions.json"),
        Bibliothecary::Dependency.new(name: "underscore", requirement: "1.0.1", type: "runtime", source: "versions.json"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("versions.json")).to be_truthy
  end
end
