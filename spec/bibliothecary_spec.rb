require 'spec_helper'

describe Bibliothecary do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  it 'lists supported package managers' do
    expect(described_class.package_managers).to eq([
          Bibliothecary::Parsers::Bower,
          Bibliothecary::Parsers::Cargo,
          Bibliothecary::Parsers::Carthage,
          Bibliothecary::Parsers::Clojars,
          Bibliothecary::Parsers::CocoaPods,
          Bibliothecary::Parsers::CPAN,
          Bibliothecary::Parsers::CRAN,
          Bibliothecary::Parsers::Dub,
          Bibliothecary::Parsers::Elm,
          Bibliothecary::Parsers::Go,
          Bibliothecary::Parsers::Hackage,
          Bibliothecary::Parsers::Haxelib,
          Bibliothecary::Parsers::Hex,
          Bibliothecary::Parsers::Julia,
          Bibliothecary::Parsers::Maven,
          Bibliothecary::Parsers::Meteor,
          Bibliothecary::Parsers::NPM,
          Bibliothecary::Parsers::Nuget,
          Bibliothecary::Parsers::Packagist,
          Bibliothecary::Parsers::Pub,
          Bibliothecary::Parsers::Pypi,
          Bibliothecary::Parsers::Rubygems,
          Bibliothecary::Parsers::Shard,
          Bibliothecary::Parsers::SwiftPM
        ])
  end

  it 'identifys manifests from a list of file paths' do
    expect(described_class.identify_manifests(['package.json', 'README.md', 'index.js'])).to eq([
      'package.json'
      ])
  end

  it 'identifys manifests from a list of file paths except ignored ones' do
    expect(described_class.identify_manifests(['package.json', 'bower_components/package.json', 'README.md', 'index.js'])).to eq([
      'package.json'
      ])
  end

  it 'analyses contents of a file' do
    expect(described_class.analyse_file('bower.json', load_fixture('bower.json'))).to eq([{
      :platform=>"bower",
      :path=>"bower.json",
      :dependencies=>[
        {:name=>"jquery", :requirement=>">= 1.9.1", :type=>"runtime"}
      ],
      :kind => 'manifest',
      success: true
    }])
  end

  it 'searches a folder for manifests and parses them' do
    Bibliothecary.configure do |config|
      config.ignored_dirs.push("fixtures")
    end
    # If we run the analysis in pwd, confusion about absolute vs.
    # relative paths is concealed because both work
    orig_pwd = Dir.pwd
    analysis = Dir.chdir("/") do
      described_class.analyse(orig_pwd)
    end
    # empty out any dependencies to make the test more reliable.
    # we test specific manifest parsers in the parsers specs
    analysis.each do |a|
      a[:dependencies] = []
    end
    expect(analysis).to eq(
      [{:platform=>"rubygems",
        :path=>"Gemfile",
        :dependencies=>[],
        :kind => 'manifest',
        success: true,
        :related_paths=>["Gemfile.lock"]},
       {:platform=>"rubygems",
        :path=>"Gemfile.lock",
        :dependencies=>[],
        :kind => 'lockfile',
        success: true,
        :related_paths=>["Gemfile"]},
       {:platform=>"rubygems",
        :path=>"bibliothecary.gemspec",
        :dependencies=>[],
        :kind => 'manifest',
        success: true,
        :related_paths=>[]}])
  end

  it 'handles a complicated folder with many manifests', :vcr do
    # If we run the analysis in pwd, confusion about absolute vs.
    # relative paths is concealed because both work
    orig_pwd = Dir.pwd
    analysis = Dir.chdir("/") do
      described_class.analyse(File.join(orig_pwd, 'spec/fixtures/multimanifest_dir'))
    end
    # empty out any dependencies to make the test more reliable.
    # we test specific manifest parsers in the parsers specs
    analysis.each do |a|
      a[:dependencies] = []
    end
    expect(analysis).to eq(
      [{:platform=>"maven",
        :path=>"com.example-hello_2.12-compile.xml",
        :dependencies=>[],
        :kind=>"lockfile",
        :success=>true,
        :related_paths=>["pom.xml"]},
       {:platform=>"maven",
        :path=>"pom.xml",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["com.example-hello_2.12-compile.xml"]},
       {:platform=>"npm",
        :path=>"package-lock.json",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["package.json"]},
       {:platform=>"npm",
        :path=>"package.json",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["package-lock.json", "yarn.lock"]},
       {:platform=>"npm",
        :path=>"yarn.lock",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["package.json"]},
       {:platform=>"pypi",
        :path=>"setup.py",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>[]},
       {:platform=>"rubygems",
        :path=>"Gemfile",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["Gemfile.lock"]},
       {:platform=>"rubygems",
        :path=>"Gemfile.lock",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["Gemfile"]},
       {:platform=>"rubygems",
        :path=>"subdir/Gemfile",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["subdir/Gemfile.lock"]},
       {:platform=>"rubygems",
        :path=>"subdir/Gemfile.lock",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["subdir/Gemfile"]}])

    Bibliothecary.reset
  end

  it 'handles a complicated folder with many manifests complaining about no-parser files', :vcr do
    # If we run the analysis in pwd, confusion about absolute vs.
    # relative paths is concealed because both work
    orig_pwd = Dir.pwd
    analysis = Dir.chdir("/") do
      described_class.analyse(File.join(orig_pwd, 'spec/fixtures/multimanifest_dir'), error_if_no_parser = true)
    end
    # empty out any dependencies to make the test more reliable.
    # we test specific manifest parsers in the parsers specs
    analysis.each do |a|
      a[:dependencies] = []
    end
    expect(analysis).to eq(
      [{:platform=>"maven",
        :path=>"com.example-hello_2.12-compile.xml",
        :dependencies=>[],
        :kind=>"lockfile",
        :success=>true,
        :related_paths=>["pom.xml"]},
       {:platform=>"maven",
        :path=>"pom.xml",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["com.example-hello_2.12-compile.xml"]},
       {:platform=>"npm",
        :path=>"package-lock.json",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["package.json"]},
       {:platform=>"npm",
        :path=>"package.json",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["package-lock.json", "yarn.lock"]},
       {:platform=>"npm",
        :path=>"yarn.lock",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["package.json"]},
       {:platform=>"pypi",
        :path=>"setup.py",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>[]},
       {:platform=>"rubygems",
        :path=>"Gemfile",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["Gemfile.lock"]},
       {:platform=>"rubygems",
        :path=>"Gemfile.lock",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["Gemfile"]},
       {:platform=>"rubygems",
        :path=>"subdir/Gemfile",
        :dependencies=>[],
        :kind=>"manifest",
        success: true,
        :related_paths=>["subdir/Gemfile.lock"]},
       {:platform=>"rubygems",
        :path=>"subdir/Gemfile.lock",
        :dependencies=>[],
        :kind=>"lockfile",
        success: true,
        :related_paths=>["subdir/Gemfile"]},
       {:platform=>"unknown",
        :path=>"unknown_non_manifest.txt",
        :dependencies=>[],
        :kind=>"unknown",
        :success=>false,
        :error_message=>"No parser for this file type"}])

    Bibliothecary.reset
  end

  it 'allows customization of config options' do
    Bibliothecary.configure do |config|
      config.ignored_dirs = ['foobar']
    end

    expect(Bibliothecary.ignored_dirs).to eq(['foobar'])

    Bibliothecary.reset
  end

  it 'allows customization of config options' do
    Bibliothecary.configure do |config|
      config.ignored_dirs = ['foobar']
    end

    expect(Bibliothecary.ignored_dirs).to eq(['foobar'])
  end

  it 'allows resetting of config options' do
    Bibliothecary.configure do |config|
      config.carthage_parser_host = 'http://foobar.com'
    end

    Bibliothecary.reset

    expect(Bibliothecary.configuration.carthage_parser_host).to eq('https://carthage.libraries.io')
  end

  it 'properly ignores directories based on ignored_dirs' do
    Bibliothecary.configure do |config|
      config.ignored_dirs.push("spec")
    end

    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| /^\.\/spec/.match(item) }).to eq []
  end

  it 'does not include directories in file list' do
    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| FileTest.directory?(item) }).to eq []
  end
end
