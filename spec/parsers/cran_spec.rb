require 'spec_helper'

describe Bibliothecary::Parsers::CRAN do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('cran')
  end

  it 'parses dependencies from DESCRIPTION' do
    expect(described_class.analyse_contents('DESCRIPTION', load_fixture('DESCRIPTION'))).to eq({
      :platform=>"cran",
      :path=>"DESCRIPTION",
      :dependencies=>[
        {:name=>"R", :version=>">= 3.1", :type=>"depends"},
        {:name=>"digest", :version=>"*", :type=>"imports"},
        {:name=>"grid", :version=>"*", :type=>"imports"},
        {:name=>"gtable", :version=>">= 0.1.1", :type=>"imports"},
        {:name=>"MASS", :version=>"*", :type=>"imports"},
        {:name=>"plyr", :version=>">= 1.7.1", :type=>"imports"},
        {:name=>"reshape2", :version=>"*", :type=>"imports"},
        {:name=>"scales", :version=>">= 0.3.0", :type=>"imports"},
        {:name=>"stats", :version=>"*", :type=>"imports"},
        {:name=>"covr", :version=>"*", :type=>"suggests"},
        {:name=>"ggplot2movies", :version=>"*", :type=>"suggests"},
        {:name=>"hexbin", :version=>"*", :type=>"suggests"},
        {:name=>"Hmisc", :version=>"*", :type=>"suggests"},
        {:name=>"lattice", :version=>"*", :type=>"suggests"},
        {:name=>"mapproj", :version=>"*", :type=>"suggests"},
        {:name=>"maps", :version=>"*", :type=>"suggests"},
        {:name=>"maptools", :version=>"*", :type=>"suggests"},
        {:name=>"mgcv", :version=>"*", :type=>"suggests"},
        {:name=>"multcomp", :version=>"*", :type=>"suggests"},
        {:name=>"nlme", :version=>"*", :type=>"suggests"},
        {:name=>"testthat", :version=>">= 0.11.0", :type=>"suggests"},
        {:name=>"quantreg", :version=>"*", :type=>"suggests"},
        {:name=>"knitr", :version=>"*", :type=>"suggests"},
        {:name=>"rpart", :version=>"*", :type=>"suggests"},
        {:name=>"rmarkdown", :version=>"*", :type=>"suggests"},
        {:name=>"svglite", :version=>"*", :type=>"suggests"},
        {:name=>"sp", :version=>"*", :type=>"enhances"}
      ]
    })
  end

  it 'parses dependencies from minimal DESCRIPTION file' do
    expect(described_class.analyse_contents('DESCRIPTION', load_fixture('DESCRIPTION2'))).to eq({
      :platform=>"cran",
      :path=>"DESCRIPTION",
      :dependencies=>[
        {:name=>"R", :version=>">= 2.14.1", :type=>"depends"},
        {:name=>"methods", :version=>"*", :type=>"imports"},
        {:name=>"chron", :version=>"*", :type=>"imports"},
        {:name=>"ggplot2", :version=>">= 0.9.0", :type=>"suggests"},
        {:name=>"plyr", :version=>"*", :type=>"suggests"},
        {:name=>"reshape", :version=>"*", :type=>"suggests"},
        {:name=>"reshape2", :version=>"*", :type=>"suggests"},
        {:name=>"testthat", :version=>">=0.4", :type=>"suggests"},
        {:name=>"hexbin", :version=>"*", :type=>"suggests"},
        {:name=>"fastmatch", :version=>"*", :type=>"suggests"},
        {:name=>"nlme", :version=>"*", :type=>"suggests"},
        {:name=>"xts", :version=>"*", :type=>"suggests"},
        {:name=>"bit64", :version=>"*", :type=>"suggests"},
        {:name=>"gdata", :version=>"*", :type=>"suggests"},
        {:name=>"GenomicRanges", :version=>"*", :type=>"suggests"},
        {:name=>"caret", :version=>"*", :type=>"suggests"},
        {:name=>"knitr", :version=>"*", :type=>"suggests"},
        {:name=>"curl", :version=>"*", :type=>"suggests"},
        {:name=>"zoo", :version=>"*", :type=>"suggests"},
        {:name=>"plm", :version=>"*", :type=>"suggests"}]
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('DESCRIPTION')).to be_truthy
  end
end
