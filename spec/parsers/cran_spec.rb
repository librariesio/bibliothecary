require "spec_helper"

describe Bibliothecary::Parsers::CRAN do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cran")
  end

  it "parses dependencies from DESCRIPTION" do
    expect(described_class.analyse_contents("DESCRIPTION", load_fixture("DESCRIPTION"))).to eq({
      platform: "cran",
      path: "DESCRIPTION",
      dependencies: [
        Bibliothecary::Dependency.new(name: "R", requirement: ">= 3.1", type: "depends", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "digest", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "grid", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "gtable", requirement: ">= 0.1.1", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "MASS", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "plyr", requirement: ">= 1.7.1", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "reshape2", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "scales", requirement: ">= 0.3.0", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "stats", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "covr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "ggplot2movies", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "hexbin", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "Hmisc", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "lattice", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "mapproj", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "maps", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "maptools", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "mgcv", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "multcomp", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "nlme", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "testthat", requirement: ">= 0.11.0", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "quantreg", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "knitr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "rpart", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "rmarkdown", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "svglite", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "sp", requirement: "*", type: "enhances", source: "DESCRIPTION"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from minimal DESCRIPTION file" do
    expect(described_class.analyse_contents("DESCRIPTION", load_fixture("DESCRIPTION2"))).to eq({
      platform: "cran",
      path: "DESCRIPTION",
      dependencies: [
        Bibliothecary::Dependency.new(name: "R", requirement: ">= 2.14.1", type: "depends", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "methods", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "chron", requirement: "*", type: "imports", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "ggplot2", requirement: ">= 0.9.0", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "plyr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "reshape", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "reshape2", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "testthat", requirement: ">=0.4", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "hexbin", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "fastmatch", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "nlme", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "xts", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "bit64", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "gdata", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "GenomicRanges", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "caret", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "knitr", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "curl", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "zoo", requirement: "*", type: "suggests", source: "DESCRIPTION"),
        Bibliothecary::Dependency.new(name: "plm", requirement: "*", type: "suggests", source: "DESCRIPTION"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("DESCRIPTION")).to be_truthy
  end
end
