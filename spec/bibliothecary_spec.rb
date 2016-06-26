require 'spec_helper'

describe Bibliothecary do
  it 'has a version number' do
    expect(Bibliothecary::VERSION).not_to be nil
  end

  it 'lists supported package managers' do
    expect(Bibliothecary.package_managers).to eq([
          Bibliothecary::Parsers::Bower,
          Bibliothecary::Parsers::Cargo,
          Bibliothecary::Parsers::Carthage,
          Bibliothecary::Parsers::Clojars,
          Bibliothecary::Parsers::CocoaPods,
          Bibliothecary::Parsers::CPAN,
          Bibliothecary::Parsers::Go,
          Bibliothecary::Parsers::Hex,
          Bibliothecary::Parsers::Maven,
          Bibliothecary::Parsers::Meteor,
          Bibliothecary::Parsers::NPM,
          Bibliothecary::Parsers::Nuget,
          Bibliothecary::Parsers::Packagist,
          Bibliothecary::Parsers::Pub,
          Bibliothecary::Parsers::Pypi,
          Bibliothecary::Parsers::Rubygems
        ])
  end
end
