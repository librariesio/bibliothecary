# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::CPAN do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cpan")
  end

  it "parses dependencies from META.yml" do
    expect(described_class.analyse_contents("META.yml", load_fixture("META.yml"))).to eq({
                                                                                           platform: "cpan",
                                                                                           path: "META.yml",
                                                                                           project_name: nil,
                                                                                           project_version: nil,
                                                                                           dependencies: [
        Bibliothecary::Dependency.new(platform: "cpan", name: "Digest::MD5", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "File::Temp", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "LWP", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "XML::Simple", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "perl", requirement: "5.6.0", type: "runtime", source: "META.yml"),
      ],
                                                                                           kind: "manifest",
                                                                                           success: true,
                                                                                         })
  end

  it "parses dependencies from META.json" do
    expect(described_class.analyse_contents("META.json", load_fixture("META.json"))).to eq({
                                                                                             platform: "cpan",
                                                                                             path: "META.json",
                                                                                             project_name: nil,
                                                                                             project_version: nil,
                                                                                             dependencies: [
        Bibliothecary::Dependency.new(platform: "cpan", name: "English", requirement: "1.00", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "Test::More", requirement: "0.45", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "Module::Build", requirement: "0.28", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "Getopt::Long", requirement: "2.32", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "List::Util", requirement: "1.07_00", type: "runtime", source: "META.json"),
      ],
                                                                                             kind: "manifest",
                                                                                             success: true,
                                                                                           })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("META.yml")).to be_truthy
    expect(described_class.match?("META.json")).to be_truthy
  end
end
