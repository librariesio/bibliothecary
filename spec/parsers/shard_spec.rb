# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Shard do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("shard")
  end

  it "parses dependencies from shard.yml" do
    expect(described_class.analyse_contents("shard.yml", load_fixture("shard.yml"))).to eq({
                                                                                             platform: "shard",
                                                                                             path: "shard.yml",
                                                                                             project_name: nil,
                                                                                             dependencies: [
        Bibliothecary::Dependency.new(platform: "shard", name: "frost", requirement: "*", type: "runtime", source: "shard.yml"),
        Bibliothecary::Dependency.new(platform: "shard", name: "shards", requirement: "*", type: "runtime", source: "shard.yml"),
        Bibliothecary::Dependency.new(platform: "shard", name: "common_mark", requirement: "*", type: "runtime", source: "shard.yml"),
        Bibliothecary::Dependency.new(platform: "shard", name: "minitest", requirement: ">= 0.2.0", type: "runtime", source: "shard.yml"),
        Bibliothecary::Dependency.new(platform: "shard", name: "selenium-webdriver", requirement: "*", type: "runtime", source: "shard.yml"),
      ],
                                                                                             kind: "manifest",
                                                                                             success: true,
                                                                                           })
  end

  it "parses dependencies from shard.lock" do
    expect(described_class.analyse_contents("shard.lock", load_fixture("shard.lock"))).to eq({
                                                                                               platform: "shard",
                                                                                               path: "shard.lock",
                                                                                               project_name: nil,
                                                                                               dependencies: [
        Bibliothecary::Dependency.new(platform: "shard", name: "common_mark", requirement: "0.1.0", type: "runtime", source: "shard.lock"),
        Bibliothecary::Dependency.new(platform: "shard", name: "frost", requirement: "*", type: "runtime", source: "shard.lock"),
        Bibliothecary::Dependency.new(platform: "shard", name: "minitest", requirement: "0.3.1", type: "runtime", source: "shard.lock"),
        Bibliothecary::Dependency.new(platform: "shard", name: "pg", requirement: "0.5.0", type: "runtime", source: "shard.lock"),
        Bibliothecary::Dependency.new(platform: "shard", name: "pool", requirement: "0.2.1", type: "runtime", source: "shard.lock"),
        Bibliothecary::Dependency.new(platform: "shard", name: "selenium-webdriver", requirement: "0.1.0", type: "runtime", source: "shard.lock"),
        Bibliothecary::Dependency.new(platform: "shard", name: "shards", requirement: "0.6.0", type: "runtime", source: "shard.lock"),
      ],
                                                                                               kind: "lockfile",
                                                                                               success: true,
                                                                                             })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("shard.yml")).to be_truthy
    expect(described_class.match?("shard.lock")).to be_truthy
  end
end
