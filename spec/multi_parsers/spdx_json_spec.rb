require "spec_helper"

describe Bibliothecary::MultiParsers::SpdxJson do
  let!(:parser_class) do
    k = Class.new do
      def platform_name; "npm"; end
    end

    k.send(:include, described_class)
    k
  end

  let!(:parser) { parser_class.new }

  context "spdx_json_file?" do
    it "returns true for a spdx json file" do
      contents = load_fixture("spdx2.2.json")
      result = parser.spdx_json_file?(contents)
      expect(result).to be(true)
    end

    it "returns false for a non spdx json file" do
      contents = load_fixture("vendor.json")
      result = parser.spdx_json_file?(contents)
      expect(result).to be(false)
    end

    it "returns false for a non-json json file" do
      contents = load_fixture("pom.xml")
      result = parser.spdx_json_file?(contents)
      expect(result).to be(false)
    end
  end

  it "handles an empty file" do
    expect{ parser.parse_spdx_json("{}") }.to raise_error(described_class::NoEntries)
  end

  context "with a properly formed file" do

    it "parses the file" do
      contents = load_fixture("spdx2.2.json")
      result = parser.parse_spdx_json(contents)
      pp result.length
      expect(result.length).to eq(1221)
      expect(result[0]).to eq(Bibliothecary::Dependency.new(name:"-", requirement:"0.0.1", type:"lockfile"))
      expect(result[1]).to eq(Bibliothecary::Dependency.new(name:"@ampproject/remapping", requirement:"2.2.0", type:"lockfile"))
    end
  end

  describe "get_platform" do
    it "should handle formats correctly" do
      golang_purl = "pkg:golang/github.com/path/to/package"

      expect(parser.get_platform(golang_purl)).to eq(:go)

      maven_purl = "pkg:maven/path/to/package@1.12.122"

      expect(parser.get_platform(maven_purl)).to eq(:maven)
    end
  end

  context "correct parsers implement it" do
    Bibliothecary::PURL_TYPE_MAPPING.each_value do |parser|
      constant_symbol = Bibliothecary::Parsers.constants.find { |c| c.to_s.downcase.gsub(/[^a-z]/, "") == parser.to_s.downcase.gsub(/[^a-z]/, "") }
      constant = Bibliothecary::Parsers.const_get(constant_symbol)

      # only analyzers have platform_name on the class
      if constant.respond_to?(:platform_name)
        it "#{constant_symbol} should implement Spdx" do
          expect(constant.respond_to?(:parse_spdx_json)).to eq(true)
        end
      end
    end
  end
end
