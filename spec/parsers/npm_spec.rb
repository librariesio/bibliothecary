require 'spec_helper'

describe Bibliothecary::Parsers::NPM do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('npm')
  end

  it 'parses dependencies from package.json' do
    expect(described_class.analyse_contents('package.json', load_fixture('package.json'))).to eq({
      :platform=>"npm",
      :path=>"package.json",
      :dependencies=>[
        {:name=>"babel", :requirement=>"^4.6.6", :type=>"runtime"},
        {:name=>"mocha", :requirement=>"^2.2.1", :type=>"development"}
      ]
    })
  end

  it 'parses dependencies from npm-shrinkwrap.json' do
    expect(described_class.analyse_contents('npm-shrinkwrap.json', load_fixture('npm-shrinkwrap.json'))).to eq({
      :platform=>"npm",
      :path=>"npm-shrinkwrap.json",
      :dependencies=>[
        {:name=>"babel", :requirement=>"4.7.16", :type=>"runtime"},
        {:name=>"body-parser", :requirement=>"1.13.3", :type=>"runtime"},
        {:name=>"bugsnag", :requirement=>"1.6.5", :type=>"runtime"},
        {:name=>"cookie-session", :requirement=>"1.2.0", :type=>"runtime"},
        {:name=>"debug", :requirement=>"2.2.0", :type=>"runtime"},
        {:name=>"deep-diff", :requirement=>"0.3.2", :type=>"runtime"},
        {:name=>"deep-equal", :requirement=>"1.0.0", :type=>"runtime"},
        {:name=>"express", :requirement=>"4.13.3", :type=>"runtime"},
        {:name=>"express-session", :requirement=>"1.11.3", :type=>"runtime"},
        {:name=>"jade", :requirement=>"1.11.0", :type=>"runtime"},
        {:name=>"js-yaml", :requirement=>"3.4.0", :type=>"runtime"},
        {:name=>"memwatch-next", :requirement=>"0.2.9", :type=>"runtime"},
        {:name=>"multer", :requirement=>"0.1.8", :type=>"runtime"},
        {:name=>"qs", :requirement=>"2.4.2", :type=>"runtime"},
        {:name=>"redis", :requirement=>"0.12.1", :type=>"runtime"},
        {:name=>"semver", :requirement=>"4.3.6", :type=>"runtime"},
        {:name=>"serve-static", :requirement=>"1.10.0", :type=>"runtime"},
        {:name=>"toml", :requirement=>"2.3.0", :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from yarn.lock' do
    expect(described_class.analyse_contents('yarn.lock', load_fixture('yarn.lock'))).to eq({
      :platform=>"npm",
      :path=>"yarn.lock",
      :dependencies=>[
        {"name"=>"body-parser", "version"=>"1.16.1", "type"=>"runtime"},
        {"name"=>"bytes", "version"=>"2.4.0", "type"=>"runtime"},
        {"name"=>"content-type", "version"=>"1.0.2", "type"=>"runtime"},
        {"name"=>"debug", "version"=>"2.6.1", "type"=>"runtime"},
        {"name"=>"depd", "version"=>"1.1.0", "type"=>"runtime"},
        {"name"=>"ee-first", "version"=>"1.1.1", "type"=>"runtime"},
        {"name"=>"http-errors", "version"=>"1.5.1", "type"=>"runtime"},
        {"name"=>"iconv-lite", "version"=>"0.4.15", "type"=>"runtime"},
        {"name"=>"inherits", "version"=>"2.0.3", "type"=>"runtime"},
        {"name"=>"media-typer", "version"=>"0.3.0", "type"=>"runtime"},
        {"name"=>"mime-db", "version"=>"1.26.0", "type"=>"runtime"},
        {"name"=>"mime-types", "version"=>"2.1.14", "type"=>"runtime"},
        {"name"=>"ms", "version"=>"0.7.2", "type"=>"runtime"},
        {"name"=>"on-finished", "version"=>"2.3.0", "type"=>"runtime"},
        {"name"=>"qs", "version"=>"6.2.1", "type"=>"runtime"},
        {"name"=>"raw-body", "version"=>"2.2.0", "type"=>"runtime"},
        {"name"=>"setprototypeof", "version"=>"1.0.2", "type"=>"runtime"},
        {"name"=>"statuses", "version"=>"1.3.1", "type"=>"runtime"},
        {"name"=>"type-is", "version"=>"1.6.14", "type"=>"runtime"},
        {"name"=>"unpipe", "version"=>"1.0.0", "type"=>"runtime"}
      ]
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('package.json')).to be_truthy
    expect(described_class.match?('npm-shrinkwrap.json')).to be_truthy
    expect(described_class.match?('yarn.lock')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('node_modules/foo/package.json')).to be_falsey
    expect(described_class.match?('node_modules/foo/npm-shrinkwrap.json')).to be_falsey
    expect(described_class.match?('node_modules/foo/yarn.lock')).to be_falsey
  end
end
