# frozen_string_literal: true

require "spec_helper"

def file_info(filename, parser)
  Bibliothecary::FileInfo.new(
    "spec/fixtures",
    "spec/fixtures/#{filename}",
    nil
  ).tap { |o| o.parser = parser }
end

def maven_file_info(filename)
  file_info(filename, Bibliothecary::Parsers::Maven)
end

describe Bibliothecary::Runner do
  describe "analyze_file" do
    let!(:runner) { Bibliothecary::Runner.new(Bibliothecary::Configuration.new) }
    it "should analyze a multi-parser file" do
      result = runner.analyze_file("sbom.spdx.json", load_fixture("sbom.spdx.json"))

      expect(result.map { |r| [r[:parser], r[:dependencies].size] }).to eq([
        ["spdx", 1],
      ])
    end
  end
end
