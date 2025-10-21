require 'spec_helper'

describe Bibliothecary::Parsers::Vcpkg do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('vcpkg')
  end

  it 'parses dependencies from vcpkg.json', :vcr do
    expect(described_class.analyse_contents('vcpkg.json', load_fixture('vcpkg.json'))).to eq({
      platform: "vcpkg",
      path: "vcpkg.json",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "sdl2", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "physfs", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "harfbuzz", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "fribidi", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "libogg", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "libtheora", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "libvorbis", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "opus", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "libpng", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "freetype", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "gettext", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "openal-soft", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "zlib", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "sqlite3", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "libsodium", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "curl", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "angle", requirement: "*", type: "runtime", source: "vcpkg.json"),
        Bibliothecary::Dependency.new(platform: "vcpkg", name: "basisu", requirement: "*", type: "runtime", source: "vcpkg.json")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('vcpkg.json')).to be_truthy
  end
end
