# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Haxelib do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("haxelib")
  end

  it "parses dependencies from haxelib.json" do
    expect(described_class.analyse_contents("haxelib.json", load_fixture("haxelib.json"))).to eq({
                                                                                                   platform: "haxelib",
                                                                                                   path: "haxelib.json",
                                                                                                   project_name: nil,
                                                                                                   project_version: nil,
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "haxelib", name: "lime", requirement: "2.9.1", type: "runtime", source: "haxelib.json"),
        Bibliothecary::Dependency.new(platform: "haxelib", name: "openfl", requirement: "3.6.1", type: "runtime", source: "haxelib.json"),
      ],
                                                                                                   kind: "manifest",
                                                                                                   success: true,
                                                                                                 })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("haxelib.json")).to be_truthy
  end
end
