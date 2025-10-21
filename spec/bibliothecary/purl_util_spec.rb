# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::PurlUtil do
  describe "full_name" do
    it "handles formats correctly" do
      maven_purl = PackageURL.parse("pkg:maven/cat/dog@1.2.3")
      expect(described_class.full_name(maven_purl)).to eq("cat:dog")

      npm_purl = PackageURL.parse("pkg:npm/cat/dog@1.2.3")
      expect(described_class.full_name(npm_purl)).to eq("cat/dog")
    end
  end
end
