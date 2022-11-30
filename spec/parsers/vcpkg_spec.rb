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
        {:name=>"sdl2", :requirement=>"*", :type=>"runtime"},
        {:name=>"physfs", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"harfbuzz", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"fribidi", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"libogg", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"libtheora", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"libvorbis", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"opus", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"libpng", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"freetype", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"gettext", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"openal-soft", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"zlib", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"sqlite3", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"libsodium", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"curl", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"angle", :requirement=>"*", :type=>"runtime"}, 
        {:name=>"basisu", :requirement=>"*", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('vcpkg.json')).to be_truthy
  end
end
