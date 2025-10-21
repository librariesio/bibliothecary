require "spec_helper"

describe Bibliothecary::Parsers::Hex do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("hex")
  end

  it "parses dependencies from mix.exs", :vcr do
    stub_request(:post, "https://mix.libraries.io/").
      with(
        body: load_fixture("mix.exs"),
        headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate({
        "poison" => "~> 1.3.1",
        "plug" => "~> 0.11.0",
        "cowboy" => "~> 1.0.0"
      }), headers: {})

    expect(described_class.analyse_contents("mix.exs", load_fixture("mix.exs"))).to eq({
      platform: "hex",
      path: "mix.exs",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hex", name: "poison", requirement: "~> 1.3.1", type: "runtime", source: "mix.exs"),
        Bibliothecary::Dependency.new(platform: "hex", name: "plug", requirement: "~> 0.11.0", type: "runtime", source: "mix.exs"),
        Bibliothecary::Dependency.new(platform: "hex", name: "cowboy", requirement: "~> 1.0.0", type: "runtime", source: "mix.exs"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from mix.lock", :vcr do
    stub_request(:post, "https://mix.libraries.io/lock").
      with(
        body: load_fixture("mix.lock"),
        headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate({
        "ranch" => {"version" => "1.2.1"},
        "poison" => {"version" => "2.1.0"},
        "plug" => {"version" => "1.1.6"},
        "cowlib" => {"version" => "1.0.2"},
        "cowboy" => {"version" => "1.0.4"}
      }), headers: {})

    expect(described_class.analyse_contents("mix.lock", load_fixture("mix.lock"))).to eq({
      platform: "hex",
      path: "mix.lock",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hex", name: "ranch", requirement: "1.2.1", type: "runtime", source: "mix.lock"),
        Bibliothecary::Dependency.new(platform: "hex", name: "poison", requirement: "2.1.0", type: "runtime", source: "mix.lock"),
        Bibliothecary::Dependency.new(platform: "hex", name: "plug", requirement: "1.1.6", type: "runtime", source: "mix.lock"),
        Bibliothecary::Dependency.new(platform: "hex", name: "cowlib", requirement: "1.0.2", type: "runtime", source: "mix.lock"),
        Bibliothecary::Dependency.new(platform: "hex", name: "cowboy", requirement: "1.0.4", type: "runtime", source: "mix.lock"),
      ],
      kind: "lockfile",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("mix.exs")).to be_truthy
    expect(described_class.match?("mix.lock")).to be_truthy
  end
end
