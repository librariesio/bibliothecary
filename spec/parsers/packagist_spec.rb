require 'spec_helper'

describe Bibliothecary::Parsers::Packagist do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Packagist::platform_name).to eq('packagist')
  end

  it 'parses dependencies from composer.json' do
    file = load_fixture('composer.json')

    expect(Bibliothecary::Parsers::Packagist.analyse_file('composer.json', file, 'composer.json')).to eq({
      :platform=>"packagist",
      :path=>"composer.json",
      :dependencies=>[
        {:name=>"laravel/framework", :requirement=>"5.0.*", :type=>"runtime"},
        {:name=>"phpunit/phpunit", :requirement=>"~4.0", :type=>"development"},
        {:name=>"phpspec/phpspec", :requirement=>"~2.1", :type=>"development"}
      ]
    })
  end

  it 'parses dependencies from composer.lock' do
    file = load_fixture('composer.lock')

    expect(Bibliothecary::Parsers::Packagist.analyse_file('composer.lock', file, 'composer.lock')).to eq({
      :platform=>"packagist",
      :path=>"composer.lock",
      :dependencies=>[
        {:name=>"doctrine/annotations", :requirement=>"v1.2.1", :type=>"runtime"},
        {:name=>"doctrine/cache", :requirement=>"v1.3.1", :type=>"runtime"},
        {:name=>"doctrine/collections", :requirement=>"v1.2", :type=>"runtime"},
        {:name=>"symfony/monolog-bundle", :requirement=>"v2.6.1", :type=>"runtime"},
        {:name=>"symfony/swiftmailer-bundle", :requirement=>"v2.3.8", :type=>"runtime"},
        {:name=>"symfony/symfony", :requirement=>"v2.6.1", :type=>"runtime"},
        {:name=>"twig/extensions", :requirement=>"v1.2.0", :type=>"runtime"},
        {:name=>"twig/twig", :requirement=>"v1.16.2", :type=>"runtime"}
      ]
    })
  end
end
