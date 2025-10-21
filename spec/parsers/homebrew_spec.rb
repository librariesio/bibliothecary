require 'spec_helper'

describe Bibliothecary::Parsers::Homebrew do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('homebrew')
  end

  it 'parses dependencies from Brewfile', :vcr do
    expect(described_class.analyse_contents('Brewfile', load_fixture('Brewfile'))).to eq({
      platform: "homebrew",
      path: "Brewfile",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "homebrew", name: "markdownlint-cli", requirement: "*", type: "runtime", source: "Brewfile"),
        Bibliothecary::Dependency.new(platform: "homebrew", name: "shellcheck", requirement: "*", type: "runtime", source: "Brewfile"),
        Bibliothecary::Dependency.new(platform: "homebrew", name: "shfmt", requirement: "*", type: "runtime", source: "Brewfile"),
        Bibliothecary::Dependency.new(platform: "homebrew", name: "swiftformat", requirement: "*", type: "runtime", source: "Brewfile")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from Brewfile.lock.json' do
    expect(described_class.analyse_contents('Brewfile.lock.json', load_fixture('Brewfile.lock.json'))).to eq({
      platform: "homebrew",
      path: "Brewfile.lock.json",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "homebrew", name: "markdownlint-cli", requirement: "0.32.2", type: "runtime", source: "Brewfile.lock.json"),
        Bibliothecary::Dependency.new(platform: "homebrew", name: "shellcheck", requirement: "0.8.0", type: "runtime", source: "Brewfile.lock.json"),
        Bibliothecary::Dependency.new(platform: "homebrew", name: "shfmt", requirement: "3.5.1", type: "runtime", source: "Brewfile.lock.json"),
        Bibliothecary::Dependency.new(platform: "homebrew", name: "swiftformat", requirement: "0.49.18", type: "runtime", source: "Brewfile.lock.json")
      ],
      kind: 'lockfile',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Brewfile')).to be_truthy
    expect(described_class.match?('Brewfile.lock.json')).to be_truthy
  end
end
