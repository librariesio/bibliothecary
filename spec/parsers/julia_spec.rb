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
        { name: "julia", requirement: "0.3", type: "runtime" },
        { name: "Codecs", requirement: "*", type: "runtime" },
        { name: "Colors", requirement: "0.3.4", type: "runtime" },
        { name: "Compat", requirement: "*", type: "runtime" },
        { name: "Compose", requirement: "0.3.11", type: "runtime" },
        { name: "Contour", requirement: "*", type: "runtime" },
        { name: "DataFrames", requirement: "0.4.2", type: "runtime" },
        { name: "DataStructures", requirement: "*", type: "runtime" },
        { name: "Dates", requirement: "*", type: "runtime" },
        { name: "Distributions", requirement: "*", type: "runtime" },
        { name: "Gadfly", requirement: "0.7-", type: "runtime" },
        { name: "Hexagons", requirement: "*", type: "runtime" },
        { name: "Homebrew", requirement: "*", type: "runtime" },
        { name: "Iterators", requirement: "0.1.5", type: "runtime" },
        { name: "JSON", requirement: "*", type: "runtime" },
        { name: "KernelDensity", requirement: "*", type: "runtime" },
        { name: "Loess", requirement: "*", type: "runtime" },
        { name: "Plots", requirement: "0.12 0.15", type: "runtime" },
        { name: "Showoff", requirement: "0.0.3", type: "runtime" },
        { name: "StatsBase", requirement: "*", type: "runtime" },
        { name: "WinReg", requirement: "*", type: "runtime" }
      ],
      kind: "manifest",
      success: true
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("REQUIRE")).to be_truthy
  end
end
