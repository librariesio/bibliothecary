# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::CRAN do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cran")
  end

  it "parses dependencies from DESCRIPTION" do
    expect(described_class.analyse_contents("DESCRIPTION", load_fixture("DESCRIPTION"))).to eq({
                                                                                                 platform: "cran",
                                                                                                 path: "DESCRIPTION",
                                                                                                 project_name: nil,
                                                                                                 project_version: nil,
                                                                                                 dependencies: [
        Bibliothecary::Dependency.new(platform: "cran", name: "R", requirement: ">= 3.1", type: "depends", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "digest", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "grid", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "gtable", requirement: ">= 0.1.1", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "MASS", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "plyr", requirement: ">= 1.7.1", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "reshape2", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "scales", requirement: ">= 0.3.0", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "stats", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "covr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "ggplot2movies", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "hexbin", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "Hmisc", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "lattice", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "mapproj", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "maps", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "maptools", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "mgcv", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "multcomp", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "nlme", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "testthat", requirement: ">= 0.11.0", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "quantreg", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "knitr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "rpart", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "rmarkdown", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "svglite", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "sp", requirement: "*", type: "enhances", source: "DESCRIPTION"),
      ],
                                                                                                 kind: "manifest",
                                                                                                 success: true,
                                                                                               })
  end

  it "parses dependencies from minimal DESCRIPTION file" do
    expect(described_class.analyse_contents("DESCRIPTION", load_fixture("DESCRIPTION2"))).to eq({
                                                                                                  platform: "cran",
                                                                                                  path: "DESCRIPTION",
                                                                                                  project_name: nil,
                                                                                                  project_version: nil,
                                                                                                  dependencies: [
        Bibliothecary::Dependency.new(platform: "cran", name: "R", requirement: ">= 2.14.1", type: "depends", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "methods", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "chron", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "ggplot2", requirement: ">= 0.9.0", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "plyr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "reshape", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "reshape2", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "testthat", requirement: ">=0.4", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "hexbin", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "fastmatch", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "nlme", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "xts", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "bit64", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "gdata", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "GenomicRanges", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "caret", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "knitr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "curl", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "zoo", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(platform: "cran", name: "plm", requirement: "*", type: "suggests", source: "DESCRIPTION"),
      ],
                                                                                                  kind: "manifest",
                                                                                                  success: true,
                                                                                                })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("DESCRIPTION")).to be_truthy
  end
end
