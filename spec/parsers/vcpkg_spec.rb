# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Vcpkg do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("vcpkg")
  end

  it "parses dependencies from vcpkg.json" do
    expect(described_class.analyse_contents("vcpkg.json", load_fixture("vcpkg/vcpkg.json"))).to eq(
      {
        platform: "vcpkg",
        path: "vcpkg.json",
        project_name: nil,
        dependencies: [
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "boost-system", requirement: "*", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "cpprestsdk", requirement: ">=2.10.0", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "openssl", requirement: "3.0.0#1", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "fmt", requirement: "*", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "zlib", requirement: ">=1.2.11", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "cmake", requirement: "*", type: "development", source: "vcpkg.json"),
        ],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "applies overrides to dependencies" do
    expect(described_class.analyse_contents("vcpkg.json", load_fixture("vcpkg/with-overrides.json"))).to eq(
      {
        platform: "vcpkg",
        path: "vcpkg.json",
        project_name: nil,
        dependencies: [
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "openssl", requirement: "1.1.1h#3", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "zlib", requirement: "1.2.11#9", type: "runtime", source: "vcpkg.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "boost-system", requirement: "1.80.0", type: "runtime", source: "vcpkg.json"),
        ],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "parses vcpkg.json with empty dependencies" do
    expect(described_class.analyse_contents("vcpkg.json", load_fixture("vcpkg/empty-deps.json"))).to eq(
      {
        platform: "vcpkg",
        path: "vcpkg.json",
        project_name: nil,
        dependencies: [],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "parses vcpkg.json with no dependencies field" do
    expect(described_class.analyse_contents("vcpkg.json", load_fixture("vcpkg/no-deps.json"))).to eq(
      {
        platform: "vcpkg",
        path: "vcpkg.json",
        project_name: nil,
        dependencies: [],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "matches valid vcpkg.json filepaths" do
    expect(described_class.match?("vcpkg.json")).to be_truthy
  end

  it "matches valid _generated-vcpkg-list.json filepaths" do
    expect(described_class.match?("_generated-vcpkg-list.json")).to be_truthy
  end

  it "parses dependencies from _generated-vcpkg-list.json" do
    expect(described_class.analyse_contents("_generated-vcpkg-list.json", load_fixture("vcpkg/_generated-vcpkg-list.json"))).to eq(
      {
        platform: "vcpkg",
        path: "_generated-vcpkg-list.json",
        project_name: nil,
        dependencies: [
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "fmt", requirement: "10.1.0", type: "runtime", source: "_generated-vcpkg-list.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "libpng", requirement: "1.6.50", type: "runtime", source: "_generated-vcpkg-list.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "vcpkg-cmake-config", requirement: "2024-05-23", type: "runtime", source: "_generated-vcpkg-list.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "vcpkg-cmake", requirement: "2024-04-23", type: "runtime", source: "_generated-vcpkg-list.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "zlib", requirement: "1.3.1", type: "runtime", source: "_generated-vcpkg-list.json"),
          Bibliothecary::Dependency.new(platform: "vcpkg", name: "openssl", requirement: "3.0.8#5", type: "runtime", source: "_generated-vcpkg-list.json"),
        ],
        kind: "lockfile",
        success: true,
      }
    )
  end
end
