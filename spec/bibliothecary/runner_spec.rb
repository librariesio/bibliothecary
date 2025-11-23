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

      expect(result.map { |r| [r[:platform], r[:dependencies].size] }).to eq([
        ["cargo", 0],
        ["conan", 0],
        ["conda", 0],
        ["cran", 0],
        ["go", 1],
        ["maven", 0],
        ["npm", 0],
        ["nuget", 0],
        ["packagist", 0],
        ["pypi", 0],
        ["rubygems", 0],
        ["vcpkg", 0],
      ])
    end
  end
end
