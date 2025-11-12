# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Conan do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("conan")
  end

  it "parses dependencies from v2 lockfile with one package" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/one-package.v2.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
        Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
      ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v2 lockfile with one dev package" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/one-package-dev.v2.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
        Bibliothecary::Dependency.new(platform: "conan", name: "ninja", requirement: "1.11.1", type: "development", source: "conan.lock"),
      ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v2 lockfile with two packages" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/two-packages.v2.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
        Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
        Bibliothecary::Dependency.new(platform: "conan", name: "bzip2", requirement: "1.0.8", type: "runtime", source: "conan.lock"),
      ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v2 lockfile with nested dependencies" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/nested-dependencies.v2.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.13", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "libpng", requirement: "1.6.39", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "freetype", requirement: "2.12.1", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "bzip2", requirement: "1.0.8", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "brotli", requirement: "1.0.9", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses v2 lockfile with no packages" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/empty.v2.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "filters out entries with no name in v2 lockfile" do
    result = described_class.analyse_contents("conan.lock", load_fixture("conan/no-name.v2.json"))
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
    ])
  end

  it "parses dependencies from v1 lockfile (v0.4) with one package" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/one-package.v1.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v1 lockfile (v0.4) with one dev package" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/one-package-dev.v1.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              # NOTE: ninja has context:"host" so it's classified as runtime, not development
              # V1 lockfiles don't reliably encode runtime vs build dependencies in the context field
              Bibliothecary::Dependency.new(platform: "conan", name: "ninja", requirement: "1.11.1", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v1 lockfile (v0.4) with two packages" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/two-packages.v1.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "bzip2", requirement: "1.0.8", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v1 lockfile (v0.4) with nested dependencies" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/nested-dependencies.v1.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "freetype", requirement: "2.12.1", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "libpng", requirement: "1.6.39", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.13", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "bzip2", requirement: "1.0.8", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "brotli", requirement: "1.0.9", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses v1 lockfile (v0.4) with no packages" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/empty.v1.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "filters out entries with no name in v1 lockfile (v0.4)" do
    result = described_class.analyse_contents("conan.lock", load_fixture("conan/no-name.v1.json"))
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
    ])
  end

  it "parses dependencies from v1 lockfile with revisions and one package" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/one-package.v1.revisions.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v1 lockfile with revisions and one dev package" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/one-package-dev.v1.revisions.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              # NOTE: ninja has context:"host" so it's classified as runtime, not development
              Bibliothecary::Dependency.new(platform: "conan", name: "ninja", requirement: "1.11.1", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v1 lockfile with revisions and two packages" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/two-packages.v1.revisions.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "bzip2", requirement: "1.0.8", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v1 lockfile with revisions and nested dependencies" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/nested-dependencies.v1.revisions.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "freetype", requirement: "2.12.1", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "libpng", requirement: "1.6.39", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.13", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "bzip2", requirement: "1.0.8", type: "runtime", source: "conan.lock"),
              Bibliothecary::Dependency.new(platform: "conan", name: "brotli", requirement: "1.0.9", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses v1 lockfile with revisions and no packages" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/empty.v1.revisions.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "filters out entries with no name in v1 lockfile with revisions" do
    result = described_class.analyse_contents("conan.lock", load_fixture("conan/no-name.v1.revisions.json"))
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
    ])
  end

  it "parses dependencies from v0.3 lockfile" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/old-format-0.3.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v0.2 lockfile" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/old-format-0.2.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v0.1 lockfile" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/old-format-0.1.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from v0.0 lockfile" do
    expect(described_class.analyse_contents("conan.lock", load_fixture("conan/old-format-0.0.json"))).to eq(
      {
        platform: "conan",
        path: "conan.lock",
        project_name: nil,
        dependencies: [
              Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conan.lock"),
            ],
        kind: "lockfile",
        success: true,
      }
    )
  end

  it "parses dependencies from conanfile.py with multiple packages" do
    result = described_class.analyse_contents("conanfile.py", load_fixture("conan/openstudio.conanfile.py"))

    expect(result[:platform]).to eq("conan")
    expect(result[:path]).to eq("conanfile.py")
    expect(result[:kind]).to eq("manifest")
    expect(result[:success]).to be true

    deps = result[:dependencies]
    expect(deps.length).to eq(20)

    # Check some specific dependencies
    ruby_dep = deps.find { |d| d.name == "ruby" }
    expect(ruby_dep).not_to be_nil
    expect(ruby_dep.requirement).to eq("3.2.2")
    expect(ruby_dep.type).to eq("runtime")

    boost_dep = deps.find { |d| d.name == "boost" }
    expect(boost_dep).not_to be_nil
    expect(boost_dep.requirement).to eq("1.79.0")

    # Check version range handling
    libxml2_dep = deps.find { |d| d.name == "libxml2" }
    expect(libxml2_dep).not_to be_nil
    expect(libxml2_dep.requirement).to eq("[<2.12.0]")

    zlib_dep = deps.find { |d| d.name == "zlib" }
    expect(zlib_dep).not_to be_nil
    expect(zlib_dep.requirement).to eq("[>=1.2.11 <2]")

    openssl_dep = deps.find { |d| d.name == "openssl" }
    expect(openssl_dep).not_to be_nil
    expect(openssl_dep.requirement).to eq("[>=3 <4]")
  end

  it "filters out invalid entries in conanfile.py" do
    content = <<~PYTHON
      from conan import ConanFile

      class TestConan(ConanFile):
          def requirements(self):
              self.requires("zlib/1.2.11")
              self.requires("1.2.3")  # Invalid: no package name
              self.requires("")  # Invalid: empty
    PYTHON

    result = described_class.analyse_contents("conanfile.py", content)
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(platform: "conan", name: "zlib", requirement: "1.2.11", type: "runtime", source: "conanfile.py"),
    ])
  end

  it "matches valid lockfile filepaths" do
    expect(described_class.match?("conan.lock")).to be_truthy
  end

  it "matches valid conanfile.py filepaths" do
    expect(described_class.match?("conanfile.py")).to be_truthy
  end
end
