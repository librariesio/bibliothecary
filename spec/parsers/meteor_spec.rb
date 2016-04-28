require 'spec_helper'

describe Bibliothecary::Parsers::Meteor do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Meteor::PLATFORM_NAME).to eq('meteor')
  end

  it 'parses dependencies from versions.json' do
    file = load_fixture('versions.json')

    expect(Bibliothecary::Parsers::Meteor.parse('versions.json', file)).to eq([
      {:name=>"accounts-base", :requirement=>"1.1.2", :type=>"runtime"},
      {:name=>"application-configuration", :requirement=>"1.0.3", :type=>"runtime"},
      {:name=>"base64", :requirement=>"1.0.1", :type=>"runtime"},
      {:name=>"binary-heap", :requirement=>"1.0.1", :type=>"runtime"},
      {:name=>"tracker", :requirement=>"1.0.3", :type=>"runtime"},
      {:name=>"underscore", :requirement=>"1.0.1", :type=>"runtime"}
    ])
  end
end
