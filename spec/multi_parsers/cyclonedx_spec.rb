# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::MultiParsers::CycloneDX do
  let(:unmapped_component) { "pkg:apt/krita/5.0.5" }
  let(:platform_name) { "whatever" }
  let!(:parser_class) do
    platform_name_value = platform_name
    k = Class.new
    k.send(:include, described_class)
    k.define_method(:platform_name) { platform_name_value }
    k
  end
  let!(:parser) { parser_class.new }

  it "handles malformed json" do
    expect { parser.parse_cyclonedx_json("{}") }.to raise_error(described_class::NoComponents)
  end

  it "handles malformed xml" do
    expect { parser.parse_cyclonedx_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"></bom>') }.to raise_error(described_class::NoComponents)
  end

  it "handles empty json components" do
    expect(parser.parse_cyclonedx_json('{ "components": [] }')).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles empty xml components" do
    expect(parser.parse_cyclonedx_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components></components></bom>')).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles unmapped json component" do
    expect(parser.parse_cyclonedx_json(%({ "components": [{ "purl": "#{unmapped_component}" }] }))).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles unmapped xml component" do
    expect(parser.parse_cyclonedx_xml(%(<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles no xml pragma" do
    expect(parser.parse_cyclonedx_xml(%(<bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  describe "ManifestEntriesByPlatform#parse!" do
    it "should not mutate the manifest sent in" do
      queue = [1, 2, 3]

      entries = described_class::ManifestEntriesByPlatform.new(parse_queue: queue)

      entries.parse! do |_item, _parse_queue|
        nil
      end

      expect(queue.count).to eq(3)
    end
  end

  context "correct parsers implement it" do
    Bibliothecary::PurlUtil::PURL_TYPE_MAPPING.each_value do |parser|
      constant_symbol = Bibliothecary::Parsers.constants.find { |c| c.to_s.downcase.gsub(/[^a-z]/, "") == parser.to_s.downcase.gsub(/[^a-z]/, "") }
      constant = Bibliothecary::Parsers.const_get(constant_symbol)

      # only analyzers have platform_name on the class
      next unless constant.respond_to?(:platform_name)

      it "#{constant_symbol} should implement CycloneDX" do
        expect(constant.respond_to?(:parse_cyclonedx_xml)).to eq(true)
      end
    end
  end

  context "parsing unsupported dependencies from a real multi-platform SBOM" do
    let(:platform_name) { "sbom" }

    it "ignores the dependencies by default" do
      result = parser.parse_cyclonedx_json(load_fixture("apache-airflow.cdx.json"))

      expect(result.dependencies).to be_empty
    end

    it "includes the dependencies with full_sbom: true" do
      result = parser.parse_cyclonedx_json(load_fixture("apache-airflow.cdx.json"), options: { full_sbom: true })

      expect(result.dependencies.map(&:platform).tally).to eq({
                                                                "pypi" => 456,
                                                                "deb" => 197,
                                                                "npm" => 3,
                                                                "maven" => 32,
                                                                "go" => 2,
                                                                "generic" => 1,
                                                              })
    end
  end
end
