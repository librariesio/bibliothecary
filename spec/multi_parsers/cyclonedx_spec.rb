# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::MultiParsers::CycloneDX do
  let(:unmapped_component) { "pkg:apt/krita/5.0.5" }

  let!(:parser_class) do
    k = Class.new do
      def platform_name = "whatever"
    end

    k.send(:include, described_class)
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
    expect(parser.parse_cyclonedx_json('{ "components": [] }')).to eq(nil)
  end

  it "handles empty xml components" do
    expect(parser.parse_cyclonedx_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components></components></bom>')).to eq(nil)
  end

  it "handles unmapped json component" do
    expect(parser.parse_cyclonedx_json(%({ "components": [{ "purl": "#{unmapped_component}" }] }))).to eq(nil)
  end

  it "handles unmapped xml component" do
    expect(parser.parse_cyclonedx_xml(%(<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq(nil)
  end

  it "handles no xml pragma" do
    expect(parser.parse_cyclonedx_xml(%(<bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq(nil)
  end

  describe "ManifestEntries#parse!" do
    it "should not mutate the manifest sent in" do
      queue = [1, 2, 3]

      entries = described_class::ManifestEntries.new(parse_queue: queue)

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
end
