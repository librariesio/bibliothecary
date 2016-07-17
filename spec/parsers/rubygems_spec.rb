require 'spec_helper'

describe Bibliothecary::Parsers::Rubygems do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Rubygems::platform_name).to eq('rubygems')
  end

  it 'parses dependencies from Gemfile' do
    file = load_fixture('Gemfile')

    expect(Bibliothecary::Parsers::Rubygems.analyse_file('Gemfile', file, 'Gemfile')).to eq({
      :platform=>"rubygems",
      :path=>"Gemfile",
      :dependencies=>[
        {:name=>"oj", :requirement=>">= 0", :type=>:runtime},
        {:name=>"rails", :requirement=>"= 4.2.0", :type=>:runtime},
        {:name=>"leveldb-ruby", :requirement=>"= 0.15", :type=>:runtime},
        {:name=>"spring", :requirement=>">= 0", :type=>:development},
        {:name=>"thin", :requirement=>">= 0", :type=>:development},
        {:name=>"puma", :requirement=>">= 0", :type=>:runtime},
        {:name=>"rails_12factor", :requirement=>">= 0", :type=>:runtime},
        {:name=>"bugsnag", :requirement=>">= 0", :type=>:runtime}
      ]
    })
  end

  it 'parses dependencies from gems.rb' do
    file = load_fixture('gems.rb')

    expect(Bibliothecary::Parsers::Rubygems.analyse_file('gems.rb', file, 'gems.rb')).to eq({
      :platform=>"rubygems",
      :path=>"gems.rb",
      :dependencies=>[
        {:name=>"oj", :requirement=>">= 0", :type=>:runtime},
        {:name=>"rails", :requirement=>"= 4.2.0", :type=>:runtime},
        {:name=>"leveldb-ruby", :requirement=>"= 0.15", :type=>:runtime},
        {:name=>"spring", :requirement=>">= 0", :type=>:development},
        {:name=>"thin", :requirement=>">= 0", :type=>:development},
        {:name=>"puma", :requirement=>">= 0", :type=>:runtime},
        {:name=>"rails_12factor", :requirement=>">= 0", :type=>:runtime},
        {:name=>"bugsnag", :requirement=>">= 0", :type=>:runtime}
      ]
    })
  end

  it 'parses dependencies from devise.gemspec' do
    file = load_fixture('devise.gemspec')

    expect(Bibliothecary::Parsers::Rubygems.analyse_file('devise.gemspec', file, 'devise.gemspec')).to eq({
      :platform=>"rubygems",
      :path=>"devise.gemspec",
      :dependencies=>[
        {:name=>"warden", :requirement=>"~> 1.2.3", :type=>:runtime},
        {:name=>"orm_adapter", :requirement=>"~> 0.1", :type=>:development},
        {:name=>"bcrypt", :requirement=>"~> 3.0", :type=>:runtime},
        {:name=>"thread_safe", :requirement=>"~> 0.1", :type=>:runtime},
        {:name=>"railties", :requirement=>"< 5, >= 3.2.6", :type=>:runtime},
        {:name=>"responders", :requirement=>">= 0", :type=>:runtime}
      ]
    })
  end

  it 'parses dependencies from Gemfile.lock' do
    file = load_fixture('Gemfile.lock')

    expect(Bibliothecary::Parsers::Rubygems.analyse_file('Gemfile.lock', file, 'Gemfile.lock')).to eq({
      :platform=>"rubygems",
      :path=>"Gemfile.lock",
      :dependencies=>[
        {:name=>"CFPropertyList", :requirement=>"2.3.1", :type=>"runtime"},
        {:name=>"actionmailer", :requirement=>"4.2.3", :type=>"runtime"},
        {:name=>"googleauth", :requirement=>"0.4.1", :type=>"runtime"},
        {:name=>"hashie", :requirement=>"3.4.2", :type=>"runtime"}
      ]
    })
  end
end
