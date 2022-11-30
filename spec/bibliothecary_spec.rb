require 'spec_helper'

describe Bibliothecary do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  it 'lists supported package managers' do
    expect(described_class.package_managers).to eq([
          Bibliothecary::Parsers::Actions,
          Bibliothecary::Parsers::Bower,
          Bibliothecary::Parsers::Cargo,
          Bibliothecary::Parsers::Carthage,
          Bibliothecary::Parsers::Clojars,
          Bibliothecary::Parsers::CocoaPods,
          Bibliothecary::Parsers::Conda,
          Bibliothecary::Parsers::CPAN,
          Bibliothecary::Parsers::CRAN,
          Bibliothecary::Parsers::Docker,
          Bibliothecary::Parsers::Dub,
          Bibliothecary::Parsers::Elm,
          Bibliothecary::Parsers::Go,
          Bibliothecary::Parsers::Hackage,
          Bibliothecary::Parsers::Haxelib,
          Bibliothecary::Parsers::Hex,
          Bibliothecary::Parsers::Homebrew,
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
          Bibliothecary::Parsers::SwiftPM,
          Bibliothecary::Parsers::Vcpkg
        ])
  end

  it 'identifys manifests from a list of file paths' do
    expect(described_class.identify_manifests(['package.json', 'README.md', 'index.js', 'environment.yml'])).to eq([
      'environment.yml', 'package.json'
      ])
  end

  it 'identifys manifests from a list of file paths except ignored ones' do
    expect(described_class.identify_manifests(['package.json', 'bower_components/package.json', 'README.md', 'index.js'])).to eq([
      'package.json'
      ])
  end

  it 'analyses contents of a file' do
    expect(described_class.analyse_file('bower.json', load_fixture('bower.json'))).to eq([{
      platform: "bower",
      path: "bower.json",
      dependencies: [
        { name: "jquery", requirement: ">= 1.9.1", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    }])
  end

  it 'analyses contents of a python file with [extras] format' do
    expect(described_class.analyse_file('requirements-extras.in', load_fixture('pip-compile/requirements-extras.in'))).to eq([{
      dependencies: [
        { name: "urllib3", requirement: "==1.0.0", type: "runtime" },
        { name: "django-dbfilestorage", requirement: "==1.0.0", type: "runtime" }
      ],
      kind: "manifest",
      path: "requirements-extras.in",
      platform: "pypi",
      success: true
    }])
  end

  it 'analyses contents of a file with a Byte Order Mark' do
    file_with_byte_order_mark = "\xEF\xBB\xBF{}"
    result = described_class.analyse_file('package.json', file_with_byte_order_mark)

    expect(result[0][:error_message]).to eq(nil)
    expect(result[0][:dependencies].length).to eq(0)
  end

  it 'analyses contents of a file with non-UTF8 encodings' do
    ascii_8bit_encoded_file = "\xEF\xBB\xBF{}".force_encoding(Encoding::ASCII_8BIT)
    result = described_class.analyse_file('package.json', ascii_8bit_encoded_file)

    expect(result[0][:error_message]).to eq(nil)
    expect(result[0][:dependencies].length).to eq(0)
  end

  it "aliases analyse and analyse_file" do
    expect(Bibliothecary.method(:analyse)).to eq(Bibliothecary.method(:analyze))
    expect(Bibliothecary.method(:analyse_file)).to eq(Bibliothecary.method(:analyze_file))
  end

  it 'searches a folder for manifests and parses them' do
    Bibliothecary.configure do |config|
      config.ignored_dirs.push("spec/fixtures")
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
      [{ platform: "rubygems",
        path: "Gemfile",
        dependencies: [],
        kind: 'manifest',
        success: true,
        related_paths: ["Gemfile.lock", "bibliothecary.gemspec"] },
       { platform: "rubygems",
        path: "Gemfile.lock",
        dependencies: [],
        kind: 'lockfile',
        success: true,
        related_paths: ["Gemfile", "bibliothecary.gemspec"] },
       { platform: "rubygems",
        path: "bibliothecary.gemspec",
        dependencies: [],
        kind: 'manifest',
        success: true,
        related_paths: ["Gemfile", "Gemfile.lock"] }])
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
      [{ platform: "docker",
        path: "Dockerfile",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["docker-compose.yml"] },
       { platform: "docker",
        path: "docker-compose.yml",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["Dockerfile"] },
        { platform: "maven",
        path: "com.example-hello_2.12-compile.xml",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["pom.xml"] },
       { platform: "maven",
        path: "pom.xml",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["com.example-hello_2.12-compile.xml"] },
       { platform: "npm",
        path: "package-lock.json",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["package.json"] },
       { platform: "npm",
        path: "package.json",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["package-lock.json", "yarn.lock"] },
       { platform: "npm",
        path: "yarn.lock",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["package.json"] },
       { platform: "pypi",
        path: "setup.py",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: [] },
       { platform: "rubygems",
        path: "Gemfile",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["Gemfile.lock"] },
       { platform: "rubygems",
        path: "Gemfile.lock",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["Gemfile"] },
       { platform: "rubygems",
        path: "subdir/Gemfile",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["subdir/Gemfile.lock"] },
       { platform: "rubygems",
        path: "subdir/Gemfile.lock",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["subdir/Gemfile"] }])

    Bibliothecary.reset
  end

  it 'handles a complicated folder with many manifests', :vcr do
    # If we run the analysis in pwd, confusion about absolute vs.
    # relative paths is concealed because both work
    orig_pwd = Dir.pwd
    analysis = Dir.chdir("/") do
      described_class.analyse(File.join(orig_pwd, 'spec/fixtures/multimanifest_dir'), ignore_unparseable_files: false)
    end
    # empty out any dependencies to make the test more reliable.
    # we test specific manifest parsers in the parsers specs
    analysis.each do |a|
      a[:dependencies] = []
    end

    expect(analysis).to eq(
      [{ platform: "docker", 
        path:"Dockerfile",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["docker-compose.yml"] },
       { platform: "docker",
        path: "docker-compose.yml",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["Dockerfile"] },
       { platform: "maven",
        path: "com.example-hello_2.12-compile.xml",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["pom.xml"] },
       { platform: "maven",
        path: "pom.xml",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["com.example-hello_2.12-compile.xml"] },
       { platform: "npm",
        path: "package-lock.json",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["package.json"] },
       { platform: "npm",
        path: "package.json",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["package-lock.json", "yarn.lock"] },
       { platform: "npm",
        path: "yarn.lock",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["package.json"] },
       { platform: "pypi",
        path: "setup.py",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: [] },
       { platform: "rubygems",
        path: "Gemfile",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["Gemfile.lock"] },
       { platform: "rubygems",
        path: "Gemfile.lock",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["Gemfile"] },
       { platform: "rubygems",
        path: "subdir/Gemfile",
        dependencies: [],
        kind: "manifest",
        success: true,
        related_paths: ["subdir/Gemfile.lock"] },
       { platform: "rubygems",
        path: "subdir/Gemfile.lock",
        dependencies: [],
        kind: "lockfile",
        success: true,
        related_paths: ["subdir/Gemfile"] },
      { platform: "unknown",
        path: "unknown_non_manifest.txt",
        dependencies: [],
        kind: "unknown",
        success: false,
        error_message: "No parser for this file type" }
      ])

    Bibliothecary.reset
  end

  it 'handles a dual-platformed file (pip/conda)', :vcr do
    # If we run the analysis in pwd, confusion about absolute vs.
    # relative paths is concealed because both work
    orig_pwd = Dir.pwd
    analysis = Dir.chdir("/") do
      described_class.analyse(File.join(orig_pwd, 'spec/fixtures/conda_with_pip'))
    end
    # empty out any dependencies to make the test more reliable.
    # we test specific manifest parsers in the parsers specs
    analysis.each do |a|
      a[:dependencies] = []
    end

    expect(analysis).to eq(
      [{ dependencies: [],
          kind: "manifest",
          path: "environment.yml",
          platform: "conda",
          related_paths: [],
          success: true },
        { dependencies: [],
          kind: "manifest",
          path: "environment.yml",
          platform: "pypi",
          related_paths: [],
          success: true }]
    )

    Bibliothecary.reset
  end

  it 'handles empty manifests' do
    # If we run the analysis in pwd, confusion about absolute vs.
    # relative paths is concealed because both work
    orig_pwd = Dir.pwd
    analysis = Dir.chdir("/") do
      described_class.analyse(File.join(orig_pwd, 'spec/fixtures/empty_manifests'), ignore_unparseable_files: false)
    end
    expect(analysis).to eq(
                          [{ platform: "npm",
                            path: "package.json",
                            dependencies: [],
                            kind: "manifest",
                            success: true,
                            related_paths: [] },
                           { platform: "rubygems",
                            path: "Gemfile",
                            dependencies: [],
                            kind: "manifest",
                            success: true,
                            related_paths: [] }])
    Bibliothecary.reset
  end

  it 'allows customization of config options' do
    Bibliothecary.configure do |config|
      config.ignored_dirs = ['foobar']
      config.ignored_files = ['hello']
    end

    expect(Bibliothecary.ignored_dirs).to eq(['foobar'])
    expect(Bibliothecary.ignored_files).to eq(['hello'])

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
    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| item.start_with?("spec/") }.length).to be > 1

    Bibliothecary.configure do |config|
      config.ignored_dirs.push("spec")
    end

    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| item.start_with?("spec/") }).to eq []

    Bibliothecary.reset
  end

  it 'properly ignores files based on ignored_files' do
    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| item.end_with?("spec/fixtures/package.json") }.length).to eq(1)

    Bibliothecary.configure do |config|
      config.ignored_files.push("spec/fixtures/package.json")
    end

    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| item.end_with?("spec/fixtures/package.json") }).to eq []

    Bibliothecary.reset
  end

  it 'only ignores directories that match by full relative path' do
    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| item.start_with?("spec/fixtures/") }.length).to be > 1

    Bibliothecary.configure do |config|
      config.ignored_dirs.push("fixtures")
    end

    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| item.start_with?("spec/fixtures/") }.length).to be > 1

    Bibliothecary.reset
  end

  it 'ignores directories and files correctly when doing identify_manifests' do
    all_files = ["Gemfile", "something/package.json", "something/Gemfile", "Gemfile.lock", "hello/package.json"].sort
    files = Bibliothecary.identify_manifests(all_files).sort
    expect(files).to eq(all_files)

    Bibliothecary.configure do |config|
      # should be ignored along with its child file;
      # should NOT cause Gemfile.lock to be ignored just because it
      # starts with "Gemfile"
      config.ignored_dirs.push("Gemfile")
      # should not be ignored because inside "something"
      config.ignored_dirs.push("package.json")
      # should be ignored
      config.ignored_files.push("hello/package.json")
      # should not be ignored when inside "something"
      config.ignored_files.push("package.json")
    end

    files = Bibliothecary.identify_manifests(all_files).sort
    expect(files).to eq(["Gemfile.lock", "something/Gemfile", "something/package.json"])

    Bibliothecary.reset
  end

  it 'does not include directories in file list' do
    files = Bibliothecary.load_file_list(".")
    expect(files.select {|item| FileTest.directory?(item) }).to eq []
  end

  it 'identifies all detected manifests in a subdirectory' do
    related_file_infos = Bibliothecary.find_manifests("spec/fixtures/multimanifest_dir/")
    expect(related_file_infos.length).to eq 6

    rubies = related_file_infos.select { |info| info.platform == "rubygems"}
    expect(rubies.length).to eq 2
    expect(rubies.first.lockfiles).to eq ["Gemfile.lock"]
    expect(rubies.first.manifests).to eq ["Gemfile"]
    expect(rubies.map(&:path)).to match_array [".", "subdir"]

    pythons = related_file_infos.select { |info| info.platform == "pypi"}
    expect(pythons.length).to eq 1
    expect(pythons.first.manifests).to eq ["setup.py"]
    expect(pythons.first.lockfiles).to eq []
    expect(pythons.first.path).to eq "."
  end

  it 'identifies all detected manifests in a list of manifest path strings' do
    file_infos = Bibliothecary.find_manifests_from_paths(["Gemfile", "Gemfile.lock", "go.mod", "yarn.lock"])
    expect(file_infos.count).to eq 3
    expect(file_infos.map(&:platform)).to eq ["rubygems", "go", "npm"]
  end

  it 'matches package manager from names and contents of files.' do
    file_path_contents_hash =[
      {
        file_path: "requirements.frozen",
        contents: load_fixture('pip-compile/requirements.frozen')
      }
    ]

    expect(described_class.load_file_info_list_from_contents(file_path_contents_hash).first.package_manager).to eq(Bibliothecary::Parsers::Pypi)
  end
  it 'identifies all detected manifests in a list of manifest files' do
    file_path_contents_hash = [{
      file_path: "requirements.frozen",
      contents: "#\n# This file is autogenerated by pip-compile with python 3.8\n# To update, run:\n#\n#    pip-compile requirements.in\n#\nblack==21.9b0\n\n# The following packages are considered to be unsafe in a requirements file:\n# pip\n# setuptools\n" }
    ]

    file_infos = Bibliothecary.find_manifests_from_contents(file_path_contents_hash)
    expect(file_infos.count).to eq 1
    expect(file_infos.map(&:lockfiles).flatten).to eq ["requirements.frozen"]
    expect(file_infos.map(&:platform)).to eq ["pypi"]
  end
end
