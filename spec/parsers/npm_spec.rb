require 'spec_helper'

describe Bibliothecary::Parsers::NPM do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::NPM::platform_name).to eq('npm')
  end

  it 'parses dependencies from package.json' do
    file = load_fixture('package.json')

    expect(Bibliothecary::Parsers::NPM.analyse_file('package.json', file, 'package.json')).to eq({
      :platform=>"npm",
      :path=>"package.json",
      :dependencies=>[
        {:name=>"babel", :requirement=>"^4.6.6", :type=>"runtime"},
        {:name=>"mocha", :requirement=>"^2.2.1", :type=>"development"}
      ]
    })
  end

  it 'parses dependencies from npm-shrinkwrap.json' do
    file = load_fixture('npm-shrinkwrap.json')

    expect(Bibliothecary::Parsers::NPM.analyse_file('npm-shrinkwrap.json', file, 'npm-shrinkwrap.json')).to eq({
      :platform=>"npm",
      :path=>"npm-shrinkwrap.json",
      :dependencies=>[
        {:name=>"babel", :requirement=>"4.7.16", :type=>"runtime"},
        {:name=>"body-parser", :requirement=>"1.13.3", :type=>"runtime"},
        {:name=>"bugsnag", :requirement=>"1.6.5", :type=>"runtime"},
        {:name=>"cookie-session", :requirement=>"1.2.0", :type=>"runtime"},
        {:name=>"debug", :requirement=>"2.2.0", :type=>"runtime"},
        {:name=>"deep-diff", :requirement=>"0.3.2", :type=>"runtime"},
        {:name=>"deep-equal", :requirement=>"1.0.0", :type=>"runtime"},
        {:name=>"express", :requirement=>"4.13.3", :type=>"runtime"},
        {:name=>"express-session", :requirement=>"1.11.3", :type=>"runtime"},
        {:name=>"jade", :requirement=>"1.11.0", :type=>"runtime"},
        {:name=>"js-yaml", :requirement=>"3.4.0", :type=>"runtime"},
        {:name=>"memwatch-next", :requirement=>"0.2.9", :type=>"runtime"},
        {:name=>"multer", :requirement=>"0.1.8", :type=>"runtime"},
        {:name=>"qs", :requirement=>"2.4.2", :type=>"runtime"},
        {:name=>"redis", :requirement=>"0.12.1", :type=>"runtime"},
        {:name=>"semver", :requirement=>"4.3.6", :type=>"runtime"},
        {:name=>"serve-static", :requirement=>"1.10.0", :type=>"runtime"},
        {:name=>"toml", :requirement=>"2.3.0", :type=>"runtime"}
      ]
    })
  end
end
