require 'spec_helper'

describe Bibliothecary::Parsers::CRAN do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::CRAN::platform_name).to eq('cran')
  end

  it 'parses dependencies from DESCRIPTION' do
    file = load_fixture('DESCRIPTION')

    expect(Bibliothecary::Parsers::CRAN.analyse_file('DESCRIPTION', file, 'DESCRIPTION')).to eq({
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
end
