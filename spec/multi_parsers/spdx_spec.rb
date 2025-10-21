# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::MultiParsers::Spdx do
  let!(:parser_class) do
    k = Class.new do
      def platform_name = "npm"
    end

    k.send(:include, described_class)
    k
  end

  let!(:parser) { parser_class.new }

  describe "parse_spdx_tag_value" do
    it "handles malformed SPDX" do
      expect { parser.parse_spdx_tag_value("SPDXVersion: SPDX-2.0\nSPDXID: SPDXRef-DOCUMENT\nDataLicense \n") }.to raise_error(described_class::MalformedFile)
      expect { parser.parse_spdx_tag_value("MALFORMED ") }.to raise_error(described_class::MalformedFile)
    end

    it "handles an empty file" do
      expect { parser.parse_spdx_tag_value("") }.to raise_error(described_class::NoEntries)
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
        expect(parser.parse_spdx_tag_value(file, options: { filename: "sbom.spdx" })).to eq(
          Bibliothecary::ParserResult.new(
            dependencies: [Bibliothecary::Dependency.new(platform: "npm", name: "package1", requirement: "1.0.0", type: "lockfile", source: "sbom.spdx")]
          )
        )
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
        expect(parser.parse_spdx_tag_value(file, options: { filename: "sbom.spdx" })).to eq(
          Bibliothecary::ParserResult.new(
            dependencies: [
              Bibliothecary::Dependency.new(platform: "npm", name: "package1", requirement: "1.0.0", type: "lockfile", source: "sbom.spdx"),
              Bibliothecary::Dependency.new(platform: "npm", name: "package2", requirement: "1.0.1", type: "lockfile", source: "sbom.spdx"),
            ]
          )
        )
      end
    end
  end

  describe "parse_spdx_json" do
    it "handles an empty file" do
      expect { parser.parse_spdx_json("{}") }.to raise_error(described_class::NoEntries)
    end

    context "with a properly formed file" do
      it "parses the file" do
        contents = load_fixture("spdx2.2.json")
        result = parser.parse_spdx_json(contents, options: { filename: "sbom.spdx.json" })
        expect(result).to be_a(Bibliothecary::ParserResult)
        dependencies = result.dependencies
        expect(dependencies.length).to eq(1221)
        expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "-", requirement: "0.0.1", type: "lockfile", source: "sbom.spdx.json"))
        expect(dependencies[1]).to eq(Bibliothecary::Dependency.new(platform: "npm", name: "@ampproject/remapping", requirement: "2.2.0", type: "lockfile", source: "sbom.spdx.json"))
      end
    end
  end

  context "correct parsers implement Spdx" do
    Bibliothecary::PurlUtil::PURL_TYPE_MAPPING.each_value do |parser|
      constant_symbol = Bibliothecary::Parsers.constants.find { |c| c.to_s.downcase.gsub(/[^a-z]/, "") == parser.to_s.downcase.gsub(/[^a-z]/, "") }
      constant = Bibliothecary::Parsers.const_get(constant_symbol)

      # only analyzers have platform_name on the class
      next unless constant.respond_to?(:platform_name)

      it "#{constant_symbol} should implement Spdx" do
        expect(constant.respond_to?(:parse_spdx_tag_value)).to eq(true)
      end
    end
  end
end
