# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::MultiParsers::Spdx do
  it "has a platform name" do
    expect(described_class.parser_name).to eq("spdx")
  end

  describe "parse_spdx_tag_value" do
    it "handles malformed SPDX" do
      expect { described_class.parse_spdx_tag_value("SPDXVersion: SPDX-2.0\nSPDXID: SPDXRef-DOCUMENT\nDataLicense \n") }.to raise_error(described_class::MalformedFile)
      expect { described_class.parse_spdx_tag_value("MALFORMED ") }.to raise_error(described_class::MalformedFile)
    end

    it "handles an empty file" do
      expect { described_class.parse_spdx_tag_value("") }.to raise_error(described_class::NoEntries)
    end

    context "with a file containing excessive whitespace" do
      let(:file) do
        <<~SPDX
          PackageName:     package1#{'   '}
          SPDXID:    SPDXRef-pkg-npm-package1-1.0.0#{'    '}
          PackageVersion:         1.0.0#{'  '}
          PackageSupplier:    Person: someuser#{'  '}
          PackageDownloadLocation:             https://registry.npmjs.org/package1/-/package1-1.0.0.tgz
          PackageLicenseConcluded:      MIT#{'  '}
          PackageLicenseDeclared:    MIT#{'  '}
          ExternalRef:      PACKAGE-MANAGER purl pkg:npm/package1@1.0.0
        SPDX
      end

      it "parses the file" do
        result = described_class.analyse_contents("sbom.spdx", file)
        expect(result[:dependencies]).to eq([
          Bibliothecary::Dependency.new(platform: "npm", name: "package1", requirement: "1.0.0", type: "lockfile", source: "sbom.spdx"),
        ])
      end
    end

    context "with a properly formed file" do
      let(:file) do
        <<~SPDX
          SPDXVersion: SPDX-2.0
          SPDXID: SPDXRef-DOCUMENT
          DataLicense: CC0-1.0
          DocumentName: some-project
          DocumentNamespace: https://test.com
          DocumentComment: <text>some comment</text>


          Creator: Tool: Test tool
          Creator: Organization: Test tool
          Created: #{Time.now}


          Relationship: SPDXRef-DOCUMENT CONTAINS SPDXRef-Package
          Relationship: SPDXRef-DOCUMENT DESCRIBES SPDXRef-Package

          ##### Package: package1

          PackageName: package1
          SPDXID: SPDXRef-pkg-npm-package1-1.0.0
          PackageVersion: 1.0.0
          PackageSupplier: Person: someuser
          PackageDownloadLocation: https://registry.npmjs.org/package1/-/package1-1.0.0.tgz
          PackageLicenseConcluded: MIT
          PackageLicenseDeclared: MIT
          ExternalRef: PACKAGE-MANAGER purl pkg:npm/package1@1.0.0

          ##### Package: package2

          PackageName: package2
          SPDXID: SPDXRef-pkg-npm-package2-1.0.1
          PackageVersion: 1.0.1
          PackageSupplier: Person: someuser1
          PackageDownloadLocation: https://registry.npmjs.org/package2/-/package2-1.0.1.tgz
          PackageLicenseConcluded: MIT
          PackageLicenseDeclared: MIT
          ExternalRef: PACKAGE_MANAGER purl pkg:npm/package2@1.0.1
        SPDX
      end

      it "parses the file" do
        result = described_class.analyse_contents("sbom.spdx", file)
        expect(result[:dependencies]).to eq([
          Bibliothecary::Dependency.new(platform: "npm", name: "package1", requirement: "1.0.0", type: "lockfile", source: "sbom.spdx"),
          Bibliothecary::Dependency.new(platform: "npm", name: "package2", requirement: "1.0.1", type: "lockfile", source: "sbom.spdx"),
        ])
      end
    end
  end

  describe "parse_spdx_json" do
    it "handles an empty file" do
      expect { described_class.parse_spdx_json("{}") }.to raise_error(described_class::NoEntries)
    end

    context "with a properly formed spdx 2.2 file" do
      it "parses the file" do
        contents = load_fixture("spdx2.2.json")
        result = described_class.analyse_contents("sbom.spdx.json", contents)
        dependencies = result[:dependencies]

        expect(dependencies.map(&:platform).tally).to eq({
                                                           "npm" => 1221,
                                                           "github" => 26,
                                                           "go" => 3,
                                                           "pypi" => 2,
                                                         })
        expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "-", requirement: "0.0.1", type: "lockfile", source: "sbom.spdx.json"))
        expect(dependencies[1]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "@ampproject/remapping", requirement: "2.2.0", type: "lockfile", source: "sbom.spdx.json"))
      end
    end

    context "with a properly formed spdx 2.3 file" do
      it "parses the file" do
        contents = load_fixture("spdx2.3.json")
        result = described_class.analyse_contents("sbom.spdx.json", contents)
        dependencies = result[:dependencies]

        expect(dependencies.map(&:platform).tally).to eq({
                                                           "npm" => 253,
                                                           "pypi" => 15,
                                                           "rpm" => 180,
                                                         })
        expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "@babel/code-frame", requirement: "7.0.0", type: "lockfile", source: "sbom.spdx.json"))
        expect(dependencies[1]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "ansi-styles", requirement: "3.2.1", type: "lockfile", source: "sbom.spdx.json"))
      end
    end

    context "with a properly formed spdx 3.0 file" do
      it "parses the file" do
        contents = load_fixture("spdx3.0.json")
        result = described_class.analyse_contents("sbom.spdx.json", contents)

        dependencies = result[:dependencies]

        expect(dependencies.map(&:platform).tally).to eq({
                                                           "npm" => 253,
                                                           "pypi" => 15,
                                                           "rpm" => 161,
                                                         })
        expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "pypi", name: "pip", requirement: "9.0.3", type: "lockfile", source: "sbom.spdx.json"))
        expect(dependencies[1]).to eq(Bibliothecary::Dependency.new(platform: "pypi", name: "six", requirement: "1.11.0", type: "lockfile", source: "sbom.spdx.json"))
      end
    end
  end
end
