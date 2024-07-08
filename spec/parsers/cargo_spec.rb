require "spec_helper"

describe Bibliothecary::Parsers::Cargo do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cargo")
  end

  it "parses dependencies from Cargo.toml" do
    expect(described_class.analyse_contents("Cargo.toml", load_fixture("Cargo.toml"))).to eq({
      platform: "cargo",
      path: "Cargo.toml",
      dependencies:[
        Bibliothecary::Dependency.new(name: "rustc-serialize", requirement: "*", type: "runtime"),
        Bibliothecary::Dependency.new(name: "regex", requirement: "*", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tempdir", requirement: "0.3", type: "development"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from Cargo.lock" do
    expect(described_class.analyse_contents("Cargo.lock", load_fixture("Cargo.lock"))).to eq({
      platform: "cargo",
      path: "Cargo.lock",
      dependencies:[
        Bibliothecary::Dependency.new(name: "aho-corasick", requirement: "0.7.18", type: "runtime"),
        Bibliothecary::Dependency.new(name: "fuchsia-cprng", requirement: "0.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "libc", requirement: "0.2.126", type: "runtime"),
        Bibliothecary::Dependency.new(name: "memchr", requirement: "2.5.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rand", requirement: "0.4.6", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rand_core", requirement: "0.3.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rand_core", requirement: "0.4.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rdrand", requirement: "0.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "regex", requirement: "1.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "regex-syntax", requirement: "0.6.27", type: "runtime"),
        Bibliothecary::Dependency.new(name: "remove_dir_all", requirement: "0.5.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rustc-serialize", requirement: "0.3.24", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tempdir", requirement: "0.3.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "winapi", requirement: "0.3.9", type: "runtime"),
        Bibliothecary::Dependency.new(name: "winapi-i686-pc-windows-gnu", requirement: "0.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "winapi-x86_64-pc-windows-gnu", requirement: "0.4.0", type: "runtime"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("Cargo.toml")).to be_truthy
    expect(described_class.match?("Cargo.lock")).to be_truthy
  end
end
