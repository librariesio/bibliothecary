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
        {:name=>"R", :requirement=>">= 3.1", :type=>"depends"},
        {:name=>"digest", :requirement=>"*", :type=>"imports"},
        {:name=>"grid", :requirement=>"*", :type=>"imports"},
        {:name=>"gtable", :requirement=>">= 0.1.1", :type=>"imports"},
        {:name=>"MASS", :requirement=>"*", :type=>"imports"},
        {:name=>"plyr", :requirement=>">= 1.7.1", :type=>"imports"},
        {:name=>"reshape2", :requirement=>"*", :type=>"imports"},
        {:name=>"scales", :requirement=>">= 0.3.0", :type=>"imports"},
        {:name=>"stats", :requirement=>"*", :type=>"imports"},
        {:name=>"covr", :requirement=>"*", :type=>"suggests"},
        {:name=>"ggplot2movies", :requirement=>"*", :type=>"suggests"},
        {:name=>"hexbin", :requirement=>"*", :type=>"suggests"},
        {:name=>"Hmisc", :requirement=>"*", :type=>"suggests"},
        {:name=>"lattice", :requirement=>"*", :type=>"suggests"},
        {:name=>"mapproj", :requirement=>"*", :type=>"suggests"},
        {:name=>"maps", :requirement=>"*", :type=>"suggests"},
        {:name=>"maptools", :requirement=>"*", :type=>"suggests"},
        {:name=>"mgcv", :requirement=>"*", :type=>"suggests"},
        {:name=>"multcomp", :requirement=>"*", :type=>"suggests"},
        {:name=>"nlme", :requirement=>"*", :type=>"suggests"},
        {:name=>"testthat", :requirement=>">= 0.11.0", :type=>"suggests"},
        {:name=>"quantreg", :requirement=>"*", :type=>"suggests"},
        {:name=>"knitr", :requirement=>"*", :type=>"suggests"},
        {:name=>"rpart", :requirement=>"*", :type=>"suggests"},
        {:name=>"rmarkdown", :requirement=>"*", :type=>"suggests"},
        {:name=>"svglite", :requirement=>"*", :type=>"suggests"},
        {:name=>"sp", :requirement=>"*", :type=>"enhances"}
      ],
      kind: 'manifest'
    })
  end

  it 'parses dependencies from minimal DESCRIPTION file' do
    expect(described_class.analyse_contents('DESCRIPTION', load_fixture('DESCRIPTION2'))).to eq({
      :platform=>"cran",
      :path=>"DESCRIPTION",
      :dependencies=>[
        {:name=>"R", :requirement=>">= 2.14.1", :type=>"depends"},
        {:name=>"methods", :requirement=>"*", :type=>"imports"},
        {:name=>"chron", :requirement=>"*", :type=>"imports"},
        {:name=>"ggplot2", :requirement=>">= 0.9.0", :type=>"suggests"},
        {:name=>"plyr", :requirement=>"*", :type=>"suggests"},
        {:name=>"reshape", :requirement=>"*", :type=>"suggests"},
        {:name=>"reshape2", :requirement=>"*", :type=>"suggests"},
        {:name=>"testthat", :requirement=>">=0.4", :type=>"suggests"},
        {:name=>"hexbin", :requirement=>"*", :type=>"suggests"},
        {:name=>"fastmatch", :requirement=>"*", :type=>"suggests"},
        {:name=>"nlme", :requirement=>"*", :type=>"suggests"},
        {:name=>"xts", :requirement=>"*", :type=>"suggests"},
        {:name=>"bit64", :requirement=>"*", :type=>"suggests"},
        {:name=>"gdata", :requirement=>"*", :type=>"suggests"},
        {:name=>"GenomicRanges", :requirement=>"*", :type=>"suggests"},
        {:name=>"caret", :requirement=>"*", :type=>"suggests"},
        {:name=>"knitr", :requirement=>"*", :type=>"suggests"},
        {:name=>"curl", :requirement=>"*", :type=>"suggests"},
        {:name=>"zoo", :requirement=>"*", :type=>"suggests"},
        {:name=>"plm", :requirement=>"*", :type=>"suggests"}
      ],
      kind: 'manifest'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('DESCRIPTION')).to be_truthy
  end
end
