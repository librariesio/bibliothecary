require 'spec_helper'

describe Bibliothecary::MultiParsers::Spdx do
  let!(:parser_class) do
    k = Class.new do
      def platform_name; "npm"; end
    end

    k.send(:include, described_class)
    k
  end

  let!(:parser) { parser_class.new }

  it "handles malformed SPDX" do
    expect { parser.parse_spdx("SPDXVersion: SPDX-2.0\nSPDXID: SPDXRef-DOCUMENT\nDataLicense: \n") }.to raise_error(described_class::MalformedFile)
    expect { parser.parse_spdx("SPDXVersion:  ") }.to raise_error(described_class::MalformedFile)
    expect { parser.parse_spdx("MALFORMED ") }.to raise_error(described_class::MalformedFile)
  end

  it "handles an empty file" do
    expect{ parser.parse_spdx("") }.to raise_error(described_class::NoEntries)
  end

  describe "properly formed file" do
    let(:file) do
      "SPDXVersion: SPDX-2.0\n" +
      "SPDXID: SPDXRef-DOCUMENT\n" +
      "DataLicense: CC0-1.0\n" +
      "DocumentName: some-project\n" +
      "DocumentNamespace: https://test.com\n" +
      "DocumentComment: <text>some comment</text>\n" +

      "\n" +
      "\n" +

      "Creator: Tool: Test tool\n" +
      "Creator: Organization: Test tool\n" +
      "Created: #{Time.now}\n" +

      "\n" +
      "\n" +

      "Relationship: SPDXRef-DOCUMENT CONTAINS SPDXRef-Package\n" +
      "Relationship: SPDXRef-DOCUMENT DESCRIBES SPDXRef-Package\n" +

      "\n" +
      "\n" +

      "PackageName: package1\n" +
      "SPDXID: SPDXRef-pkg-npm-package1-1.0.0\n" +
      "PackageVersion: 1.0.0\n" +
      "PackageSupplier: Person: someuser\n" +
      "PackageDownloadLocation: https://registry.npmjs.org/package1/-/package1-1.0.0.tgz\n" +
      "PackageLicenseConcluded: MIT\n" +
      "PackageLicenseDeclared: MIT\n" +
      "ExternalRef: PACKAGE-MANAGER purl pkg:npm/package1@1.0.0\n" +

      "\n" +
      "\n" +

      "PackageName: package2\n" +
      "SPDXID: SPDXRef-pkg-npm-package2-1.0.1\n" +
      "PackageVersion: 1.0.1\n" +
      "PackageSupplier: Person: someuser1\n" +
      "PackageDownloadLocation: https://registry.npmjs.org/package2/-/package2-1.0.1.tgz\n" +
      "PackageLicenseConcluded: MIT\n" +
      "PackageLicenseDeclared: MIT\n" +
      "ExternalRef: PACKAGE-MANAGER purl pkg:npm/package2@1.0.1"
    end

    it "handles a properly formed file" do
      expect(parser.parse_spdx(file)).to eq([
        {:name=>"package1", :requirement=>"1.0.0", :type=>"lockfile"},
        {:name=>"package2", :requirement=>"1.0.1", :type=>"lockfile"}
      ])
    end
  end


  describe 'Spdx::get_platform' do
    it 'should handle formats correctly' do
      maven = "SPDXRef-pkg-maven-ch.qos.some-package-1.1.5"

      expect(parser.get_platform(maven)).to eq(:maven)

      npm = "SPDXRef-pkg-npm-some-package2-1.0.2"

      expect(parser.get_platform(npm)).to eq(:npm)
    end
  end

  context 'correct parsers implement it' do
    Bibliothecary::MultiParsers::Spdx::PURL_TYPE_MAPPING.each_value do |parser|
      constant_symbol = Bibliothecary::Parsers.constants.find { |c| c.to_s.downcase.gsub(/[^a-z]/, '') == parser.to_s.downcase.gsub(/[^a-z]/, '') }
      constant = Bibliothecary::Parsers.const_get(constant_symbol)

      # only analyzers have platform_name on the class
      if constant.respond_to?(:platform_name)
        it "#{constant_symbol} should implement Spdx" do
          expect(constant.respond_to?(:parse_spdx)).to eq(true)
        end
      end
    end
  end
end
