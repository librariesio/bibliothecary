require 'spec_helper'

describe Bibliothecary::Parsers::Rubygems do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Rubygems::PLATFORM_NAME).to eq('Rubygems')
  end

  it 'parses dependencies from Gemfile' do
    file = load_fixture('Gemfile')

    expect(Bibliothecary::Parsers::Rubygems.parse('Gemfile', file)).to eq([
      {:name=>"oj", :requirement=>">= 0", :type=>:runtime},
      {:name=>"rails", :requirement=>"= 4.2.0", :type=>:runtime},
      {:name=>"leveldb-ruby", :requirement=>"= 0.15", :type=>:runtime},
      {:name=>"spring", :requirement=>">= 0", :type=>:development},
      {:name=>"thin", :requirement=>">= 0", :type=>:development},
      {:name=>"puma", :requirement=>">= 0", :type=>:runtime},
      {:name=>"rails_12factor", :requirement=>">= 0", :type=>:runtime},
      {:name=>"bugsnag", :requirement=>">= 0", :type=>:runtime}
    ])
  end

  it 'parses dependencies from gems.rb' do
    file = load_fixture('gems.rb')

    expect(Bibliothecary::Parsers::Rubygems.parse('gems.rb', file)).to eq([
      {:name=>"oj", :requirement=>">= 0", :type=>:runtime},
      {:name=>"rails", :requirement=>"= 4.2.0", :type=>:runtime},
      {:name=>"leveldb-ruby", :requirement=>"= 0.15", :type=>:runtime},
      {:name=>"spring", :requirement=>">= 0", :type=>:development},
      {:name=>"thin", :requirement=>">= 0", :type=>:development},
      {:name=>"puma", :requirement=>">= 0", :type=>:runtime},
      {:name=>"rails_12factor", :requirement=>">= 0", :type=>:runtime},
      {:name=>"bugsnag", :requirement=>">= 0", :type=>:runtime}
    ])
  end

  it 'parses dependencies from devise.gemspec' do
    file = load_fixture('devise.gemspec')

    expect(Bibliothecary::Parsers::Rubygems.parse('devise.gemspec', file)).to eq([
      {:name=>"warden", :requirement=>"~> 1.2.3", :type=>:runtime},
      {:name=>"orm_adapter", :requirement=>"~> 0.1", :type=>:development},
      {:name=>"bcrypt", :requirement=>"~> 3.0", :type=>:runtime},
      {:name=>"thread_safe", :requirement=>"~> 0.1", :type=>:runtime},
      {:name=>"railties", :requirement=>"< 5, >= 3.2.6", :type=>:runtime},
      {:name=>"responders", :requirement=>">= 0", :type=>:runtime}
    ])
  end

  it 'parses dependencies from Gemfile.lock' do
    file = load_fixture('Gemfile.lock')

    expect(Bibliothecary::Parsers::Rubygems.parse('Gemfile.lock', file)).to eq([
      {:name=>"CFPropertyList", :requirement=>"2.3.1", :type=>"runtime"},
      {:name=>"actionmailer", :requirement=>"4.2.3", :type=>"runtime"},
      {:name=>"googleauth", :requirement=>"0.4.1", :type=>"runtime"},
      {:name=>"hashie", :requirement=>"3.4.2", :type=>"runtime"}
    ])
  end
end
