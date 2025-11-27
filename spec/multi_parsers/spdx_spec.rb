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

    context "with full_sbom option" do
      let(:file_with_unmapped) do
        <<~SPDX
          PackageName: alpine-base
          SPDXID: SPDXRef-pkg-alpine-base
          PackageVersion: 3.18.0
          ExternalRef: PACKAGE-MANAGER purl pkg:alpine/alpine-base@3.18.0

          PackageName: package1
          SPDXID: SPDXRef-pkg-npm-package1
          PackageVersion: 1.0.0
          ExternalRef: PACKAGE-MANAGER purl pkg:npm/package1@1.0.0
        SPDX
      end

      it "includes unmapped packages" do
        result = described_class.parse_spdx_tag_value(file_with_unmapped, options: { full_sbom: true, filename: "sbom.spdx" })
        expect(result.dependencies.length).to eq(2)

        alpine_dep = result.dependencies.find { |d| d.name == "alpine-base" }
        expect(alpine_dep).not_to be_nil
        expect(alpine_dep.platform).to eq("alpine")
        expect(alpine_dep.requirement).to eq("3.18.0")

        npm_dep = result.dependencies.find { |d| d.name == "package1" }
        expect(npm_dep).not_to be_nil
        expect(npm_dep.platform).to eq("npm")
        expect(npm_dep.requirement).to eq("1.0.0")
      end

      it "filters unmapped packages by default" do
        result = described_class.parse_spdx_tag_value(file_with_unmapped, options: { filename: "sbom.spdx" })
        expect(result.dependencies.length).to eq(1)
        expect(result.dependencies.first.name).to eq("package1")
        expect(result.dependencies.first.platform).to eq("npm")
      end
    end
  end

  describe "parse_spdx_json" do
    it "handles an empty file" do
      expect { described_class.parse_spdx_json("{}") }.to raise_error(described_class::NoEntries)
    end

    context "with a properly formed file" do
      it "parses the file" do
        contents = load_fixture("spdx2.2.json")
        result = described_class.analyse_contents("sbom.spdx.json", contents)
        dependencies = result[:dependencies]

        expect(dependencies.map(&:platform).tally).to eq({
                                                           "npm" => 1221,
                                                           "go" => 3,
                                                           "pypi" => 2,
                                                         })
        expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "-", requirement: "0.0.1", type: "lockfile", source: "sbom.spdx.json"))
        expect(dependencies[1]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "@ampproject/remapping", requirement: "2.2.0", type: "lockfile", source: "sbom.spdx.json"))
      end
    end

    context "with full_sbom option" do
      let(:json_with_unmapped) do
        {
          "packages" => [
            {
              "name" => "alpine-base",
              "versionInfo" => "3.18.0",
              "externalRefs" => [
                {
                  "referenceType" => "purl",
                  "referenceLocator" => "pkg:alpine/alpine-base@3.18.0",
                },
              ],
            },
            {
              "name" => "express",
              "versionInfo" => "4.17.1",
              "externalRefs" => [
                {
                  "referenceType" => "purl",
                  "referenceLocator" => "pkg:npm/express@4.17.1",
                },
              ],
            },
          ],
        }.to_json
      end

      it "includes unmapped packages" do
        result = described_class.parse_spdx_json(json_with_unmapped, options: { full_sbom: true, filename: "sbom.spdx.json" })
        expect(result.dependencies.length).to eq(2)

        alpine_dep = result.dependencies.find { |d| d.name == "alpine-base" }
        expect(alpine_dep).not_to be_nil
        expect(alpine_dep.platform).to eq("alpine")
        expect(alpine_dep.requirement).to eq("3.18.0")

        npm_dep = result.dependencies.find { |d| d.name == "express" }
        expect(npm_dep).not_to be_nil
        expect(npm_dep.platform).to eq("npm")
        expect(npm_dep.requirement).to eq("4.17.1")
      end

      it "filters unmapped packages by default" do
        result = described_class.parse_spdx_json(json_with_unmapped, options: { filename: "sbom.spdx.json" })
        expect(result.dependencies.length).to eq(1)
        expect(result.dependencies.first.name).to eq("express")
        expect(result.dependencies.first.platform).to eq("npm")
      end
    end
  end
end
