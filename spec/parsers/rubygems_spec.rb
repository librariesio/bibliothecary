require 'spec_helper'

describe Bibliothecary::Parsers::Rubygems do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('rubygems')
  end

  it 'parses dependencies from Gemfile' do
    expect(described_class.analyse_contents('Gemfile', load_fixture('Gemfile'))).to eq({
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
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from gems.rb' do
    expect(described_class.analyse_contents('gems.rb', load_fixture('gems.rb'))).to eq({
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
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from devise.gemspec' do
    expect(described_class.analyse_contents('devise.gemspec', load_fixture('devise.gemspec'))).to eq({
      :platform=>"rubygems",
      :path=>"devise.gemspec",
      :dependencies=>[
        {:name=>"warden", :requirement=>"~> 1.2.3", :type=>:runtime},
        {:name=>"orm_adapter", :requirement=>"~> 0.1", :type=>:development},
        {:name=>"bcrypt", :requirement=>"~> 3.0", :type=>:runtime},
        {:name=>"thread_safe", :requirement=>"~> 0.1", :type=>:runtime},
        {:name=>"railties", :requirement=>">= 3.2.6, < 5", :type=>:runtime},
        {:name=>"responders", :requirement=>">= 0", :type=>:runtime}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Gemfile.lock' do
    expect(described_class.analyse_contents('Gemfile.lock', load_fixture('Gemfile.lock'))).to eq({
      :platform=>"rubygems",
      :path=>"Gemfile.lock",
      :dependencies=>[
        {:name=>"CFPropertyList", :requirement=>"2.3.1", :type=>"runtime"},
        {:name=>"actionmailer", :requirement=>"4.2.3", :type=>"runtime"},
        {:name=>"googleauth", :requirement=>"0.4.1", :type=>"runtime"},
        {:name=>"hashie", :requirement=>"3.4.2", :type=>"runtime"}
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from Gemfile.lock with windows line endings' do
    expect(
      described_class.analyse_contents(
        "Gemfile.lock",
        "GEM\r\n  remote: https://rubygems.org/\r\n  specs:\r\n    rails (5.2.3)\r\n")).to eq({
          :platform=>"rubygems",
          :path=>"Gemfile.lock",
          :dependencies=>[
            {:name=>"rails", :requirement=>"5.2.3", :type=>"runtime"},
          ],
          kind: 'lockfile',
          success: true
        })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('devise.gemspec')).to be_truthy
    expect(described_class.match?('Gemfile')).to be_truthy
    expect(described_class.match?('Gemfile.lock')).to be_truthy
    expect(described_class.match?('gems.rb')).to be_truthy
    expect(described_class.match?('gems.locked')).to be_truthy
  end
end
