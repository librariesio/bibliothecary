# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::ParserResult do
  describe "#new" do
    it "sets all properties" do
      dep = described_class.new(
        dependencies: [],
        project_name: "foo"
      )

      expect(dep.dependencies).to eq([])
      expect(dep.project_name).to eq("foo")
    end

    it "only requires dependencies" do
      expect { described_class.new }.to raise_error(ArgumentError, "missing keyword: :dependencies")
    end

    it "can check equality" do
      result = Bibliothecary::ParserResult.new(dependencies: [], project_name: "foo")

      expect(result).to eq(Bibliothecary::ParserResult.new(dependencies: [], project_name: "foo"))
      expect(result).to_not eq(Bibliothecary::ParserResult.new(dependencies: [], project_name: "bar"))
    end

    it "can be deduped" do
      result1 = Bibliothecary::ParserResult.new(dependencies: [], project_name: "bar")
      result2 = Bibliothecary::ParserResult.new(dependencies: [], project_name: "baz")
      result3 = Bibliothecary::ParserResult.new(dependencies: [], project_name: "bar")

      expect([result1, result2, result3].uniq).to eq([result1, result2])
    end

    it "can be serialized with to_h" do
      attrs = {
        project_name: "foo",
        dependencies: [],
      }

      dep = described_class.new(**attrs)

      expect(dep.to_h).to eq(attrs)
    end
  end
end
