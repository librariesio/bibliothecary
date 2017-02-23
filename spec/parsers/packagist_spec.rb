require 'spec_helper'

describe Bibliothecary::Parsers::Packagist do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('packagist')
  end

  it 'parses dependencies from composer.json' do
    expect(described_class.analyse_contents('composer.json', load_fixture('composer.json'))).to eq({
      :platform=>"packagist",
      :path=>"composer.json",
      :dependencies=>[
        {:name=>"laravel/framework", :requirement=>"5.0.*", :type=>"runtime"},
        {:name=>"phpunit/phpunit", :requirement=>"~4.0", :type=>"development"},
        {:name=>"phpspec/phpspec", :requirement=>"~2.1", :type=>"development"}
      ],
      kind: 'manifest'
    })
  end

  it 'parses dependencies from composer.lock' do
    expect(described_class.analyse_contents('composer.lock', load_fixture('composer.lock'))).to eq({
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
      ],
      kind: 'lockfile'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('composer.json')).to be_truthy
    expect(described_class.match?('composer.lock')).to be_truthy
  end
end
