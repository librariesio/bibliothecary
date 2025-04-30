# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Pub do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("pub")
  end

  it "parses dependencies from pubspec.yaml" do
    expect(described_class.analyse_contents("pubspec.yaml", load_fixture("pubspec.yaml"))).to eq({
                                                                                                   platform: "pub",
                                                                                                   path: "pubspec.yaml",
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(name: "analyzer", requirement: ">=0.22.0 <0.25.0", type: "runtime", source: "pubspec.yaml"),
        Bibliothecary::Dependency.new(name: "args", requirement: ">=0.12.0 <0.13.0", type: "runtime", source: "pubspec.yaml"),
        Bibliothecary::Dependency.new(name: "benchmark_harness", requirement: ">=1.0.0 <2.0.0", type: "development", source: "pubspec.yaml"),
        Bibliothecary::Dependency.new(name: "guinness", requirement: ">=0.1.9 <0.2.0", type: "development", source: "pubspec.yaml"),
      ],
                                                                                                   kind: "manifest",
                                                                                                   success: true,
                                                                                                 })
  end

  it "parses dependencies from pubspec.lock" do
    expect(described_class.analyse_contents("pubspec.lock", load_fixture("pubspec.lock"))).to eq({
                                                                                                   platform: "pub",
                                                                                                   path: "pubspec.lock",
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(name: "analyzer", requirement: "0.24.6", type: "runtime", source: "pubspec.lock"),
        Bibliothecary::Dependency.new(name: "args", requirement: "0.12.2+6", type: "runtime", source: "pubspec.lock"),
        Bibliothecary::Dependency.new(name: "barback", requirement: "0.15.2+7", type: "runtime", source: "pubspec.lock"),
        Bibliothecary::Dependency.new(name: "which", requirement: "0.1.3", type: "runtime", source: "pubspec.lock"),
      ],
                                                                                                   kind: "lockfile",
                                                                                                   success: true,
                                                                                                 })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("pubspec.yaml")).to be_truthy
    expect(described_class.match?("pubspec.lock")).to be_truthy
  end
end
