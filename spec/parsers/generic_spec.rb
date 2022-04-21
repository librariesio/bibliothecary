require 'spec_helper'

describe Bibliothecary::Parsers::Generic do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('generic')
  end

  it 'parses dependencies from dependencies.csv' do
    expect(described_class.analyse_contents('dependencies.csv', load_fixture('dependencies.csv'))).to eq({
      :platform=>"maven",
      :path=>"dependencies.csv",
      :dependencies=>[
        {:name=>"com.example:something", :requirement=>"1.0.3", :type=>"runtime"},
        {:name=>"com.example:something-dev", :requirement=>"1.0.4", :type=>"development"}
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('dependencies.csv')).to be_truthy
  end

  it 'raises an error for blank required fields' do
    csv = %Q!platform,name,requirement\ngo,something,!
    result = described_class.analyse_contents('dependencies.csv', csv)
    expect(result[:error_message]).to eq("dependencies.csv: missing field 'requirement' on line 2")
  end
end
