require 'spec_helper'

describe Bibliothecary do
  it 'has a version number' do
    expect(Bibliothecary::VERSION).not_to be nil
  end

  it 'lists supported package managers' do
    expect(Bibliothecary.package_managers).to eq([
          Bibliothecary::Parsers::Bower,
          Bibliothecary::Parsers::Cargo,
          Bibliothecary::Parsers::CocoaPods,
          Bibliothecary::Parsers::CPAN,
          Bibliothecary::Parsers::Meteor,
          Bibliothecary::Parsers::NPM,
          Bibliothecary::Parsers::Packagist,
          Bibliothecary::Parsers::Pub,
          Bibliothecary::Parsers::Rubygems
        ])
  end
end
