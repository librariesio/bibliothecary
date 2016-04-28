require 'spec_helper'

describe Bibliothecary do
  it 'has a version number' do
    expect(Bibliothecary::VERSION).not_to be nil
  end

  it 'lists supported package managers' do
    expect(Bibliothecary.package_managers).to eq([
          Bibliothecary::Parsers::NPM,
          Bibliothecary::Parsers::Bower,
          Bibliothecary::Parsers::Packagist,
          Bibliothecary::Parsers::CPAN,
          Bibliothecary::Parsers::Meteor,
          Bibliothecary::Parsers::Cargo,
          Bibliothecary::Parsers::Pub,
          Bibliothecary::Parsers::Rubygems,
          Bibliothecary::Parsers::CocoaPods
        ])
  end
end
