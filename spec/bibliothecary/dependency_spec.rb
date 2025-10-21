# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Dependency do
  describe "#new" do
    it "sets all properties" do
      dep = described_class.new(
        name: "foo",
        requirement: "1.0.0",
        platform: "maven",
        type: "runtime",
        direct: true,
        deprecated: true,
        local: true,
        optional: true,
        original_name: "foo-alias",
        original_requirement: "1.0.0.rc1",
        source: "package.json"
      )

      expect(dep.name).to eq("foo")
      expect(dep.requirement).to eq("1.0.0")
      expect(dep.platform).to eq("maven")
      expect(dep.type).to eq("runtime")
      expect(dep.direct).to eq(true)
      expect(dep.deprecated).to eq(true)
      expect(dep.local).to eq(true)
      expect(dep.optional).to eq(true)
      expect(dep.original_name).to eq("foo-alias")
      expect(dep.original_requirement).to eq("1.0.0.rc1")
      expect(dep.source).to eq("package.json")
    end

    it "only requires name and requirement" do
      expect { subject.new }.to raise_error(ArgumentError, "missing keywords: :name, :requirement, :platform")
    end

    it "can check equality" do
      dep = Bibliothecary::Dependency.new(name: "foo", requirement: "1.0.0", platform: "rubygems")

      expect(dep).to eq(Bibliothecary::Dependency.new(name: "foo", requirement: "1.0.0", platform: "rubygems"))
      expect(dep).to_not eq(Bibliothecary::Dependency.new(name: "foo", requirement: "2.0.0", platform: "rubygems"))
    end

    it "can be deduped" do
      dep1 = Bibliothecary::Dependency.new(name: "foo", requirement: "1.0.0", platform: "rubygems")
      dep2 = Bibliothecary::Dependency.new(name: "foo", requirement: "2.0.0", platform: "rubygems")
      dep3 = Bibliothecary::Dependency.new(name: "foo", requirement: "2.0.0", platform: "rubygems")

      expect([dep1, dep2, dep3].uniq).to eq([dep1, dep2])
    end

    it "can be serialized with to_h" do
      attrs = {
        name: "foo",
        requirement: "1.0.0",
        platform: "maven",
        type: "runtime",
        direct: true,
        deprecated: true,
        local: true,
        optional: true,
        original_name: "foo-alias",
        original_requirement: "1.0.0.rc1",
        source: "package.json",
      }

      dep = described_class.new(**attrs)

      expect(dep.to_h).to eq(attrs)
    end

    it "sets empty requirement to wildcard" do
      dependency = described_class.new(name: "foo", platform: "rubygems", requirement: nil)
      expect(dependency.requirement).to eq("*")
    end

    it "can be read like a hash" do
      dependency = described_class.new(name: "foo", platform: "rubygems", requirement: nil)
      expect(dependency[:name]).to eq("foo")
    end
  end
end
