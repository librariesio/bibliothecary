require "spec_helper"

describe Bibliothecary::Parsers::Julia do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("julia")
  end

  it "parses dependencies from REQUIRE" do
    expect(described_class.analyse_contents("REQUIRE", load_fixture("REQUIRE"))).to eq({
      platform: "julia",
      path: "REQUIRE",
      dependencies: [
        Bibliothecary::Dependency.new(name: "julia", requirement: "0.3", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Codecs", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Colors", requirement: "0.3.4", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Compat", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Compose", requirement: "0.3.11", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Contour", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "DataFrames", requirement: "0.4.2", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "DataStructures", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Dates", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Distributions", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Gadfly", requirement: "0.7-", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Hexagons", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Homebrew", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Iterators", requirement: "0.1.5", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "JSON", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "KernelDensity", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Loess", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Plots", requirement: "0.12 0.15", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "Showoff", requirement: "0.0.3", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "StatsBase", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(name: "WinReg", requirement: "*", type: "runtime", source: "REQUIRE"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("REQUIRE")).to be_truthy
  end
end
