# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Nuget::NugetRequirement do
  describe "#convert_to_semver_requirement" do
    it "converts simple version to >= constraint" do
      expect(described_class.convert_to_semver_requirement("1.0")).to eq(">= 1.0")
      expect(described_class.convert_to_semver_requirement("1.2.3-alpha.0.beta")).to eq(">= 1.2.3-alpha.0.beta")
    end

    it "converts inclusive lower bound range to >= constraint" do
      expect(described_class.convert_to_semver_requirement("[1.0,)")).to eq(">= 1.0")
      expect(described_class.convert_to_semver_requirement("[1.2.3-alpha.0.beta,)")).to eq(">= 1.2.3-alpha.0.beta")
    end

    it "converts exclusive lower bound range to > constraint" do
      expect(described_class.convert_to_semver_requirement("(1.0,)")).to eq("> 1.0")
      expect(described_class.convert_to_semver_requirement("(1.2.3-alpha.0.beta,)")).to eq("> 1.2.3-alpha.0.beta")
    end

    it "converts exact version range to exact constraint" do
      expect(described_class.convert_to_semver_requirement("[1.0]")).to eq("1.0")
      expect(described_class.convert_to_semver_requirement("[1.2.3-alpha.0.beta]")).to eq("1.2.3-alpha.0.beta")
    end

    it "converts inclusive upper bound range to <= constraint" do
      expect(described_class.convert_to_semver_requirement("(,1.0]")).to eq("<= 1.0")
      expect(described_class.convert_to_semver_requirement("(,1.2.3-alpha.0.beta]")).to eq("<= 1.2.3-alpha.0.beta")
    end

    it "converts exclusive upper bound range to < constraint" do
      expect(described_class.convert_to_semver_requirement("(,1.0)")).to eq("< 1.0")
      expect(described_class.convert_to_semver_requirement("(,1.2.3-alpha.0.beta)")).to eq("< 1.2.3-alpha.0.beta")
    end

    it "converts inclusive range to >= <= constraints" do
      expect(described_class.convert_to_semver_requirement("[1.0,2.0]")).to eq(">= 1.0 <= 2.0")
      expect(described_class.convert_to_semver_requirement("[1.2.3-alpha.0.beta,2.4.5-rc.1]")).to eq(">= 1.2.3-alpha.0.beta <= 2.4.5-rc.1")
    end

    it "converts exclusive range to > < constraints" do
      expect(described_class.convert_to_semver_requirement("(1.0,2.0)")).to eq("> 1.0 < 2.0")
      expect(described_class.convert_to_semver_requirement("(1.2.3-alpha.0.beta,2.4.5-rc.1)")).to eq("> 1.2.3-alpha.0.beta < 2.4.5-rc.1")
    end

    it "converts inclusive lower, exclusive upper range to >= < constraints" do
      expect(described_class.convert_to_semver_requirement("[1.0,2.0)")).to eq(">= 1.0 < 2.0")
      expect(described_class.convert_to_semver_requirement("[1.2.3-alpha.0.beta,2.4.5-rc.1)")).to eq(">= 1.2.3-alpha.0.beta < 2.4.5-rc.1")
    end

    it "converts exclusive lower, inclusive upper range to > <= constraints" do
      expect(described_class.convert_to_semver_requirement("(1.0,2.0]")).to eq("> 1.0 <= 2.0")
      expect(described_class.convert_to_semver_requirement("(1.2.3-alpha.0.beta,2.4.5-rc.1]")).to eq("> 1.2.3-alpha.0.beta <= 2.4.5-rc.1")
    end

    it "raises an error for invalid range format" do
      expect { described_class.convert_to_semver_requirement("(1.0)") }.to raise_error(ArgumentError)
      expect { described_class.convert_to_semver_requirement("(1.2.3-alpha.0.beta)") }.to raise_error(ArgumentError)
    end

    it "converts wildcard version to ~> constraint" do
      expect(described_class.convert_to_semver_requirement("1.*")).to eq("~> 1.0")
    end

    it "converts patch wildcard version to >= constraint" do
      # In node semver ranges, this would evaluate to "~> 1.2.0 <1.3.0", but
      # a manual test with a csproj requirement for "Newtonsoft.Json" of "4.7.*"
      # when no 4.7 line exists results in a resolved version of "5.0.1".
      expect(described_class.convert_to_semver_requirement("1.2.*")).to eq(">= 1.0")
    end

    it "converts full wildcard to >= 0 constraint" do
      expect(described_class.convert_to_semver_requirement("*")).to eq(">= 0")
    end

    it "converts nil to wildcard" do
      expect(described_class.convert_to_semver_requirement(nil)).to eq(">= 0")
    end
  end
end
