require "spec_helper"

describe Bibliothecary::Parsers::SwiftPM do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("swiftpm")
  end

  it "parses dependencies from Package.swift", :vcr do
    expect(described_class.analyse_contents("Package.swift", load_fixture("Package.swift"))).to eq({
      platform: "swiftpm",
      path: "Package.swift",
      dependencies: [
        { name: "github.com/qutheory/vapor", requirement: "0.12.0 - 0.12.9223372036854775807", type: "runtime" },
        { name: "github.com/czechboy0/Tasks", requirement: "0.2.0 - 0.2.9223372036854775807", type: "runtime" },
        { name: "github.com/czechboy0/Environment", requirement: "0.4.0 - 0.4.9223372036854775807", type: "runtime" },
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("Package.swift")).to be_truthy
  end
end
