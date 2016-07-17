require 'spec_helper'

describe Bibliothecary::Parsers::Go do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Go::platform_name).to eq('go')
  end

  it 'parses dependencies from glide.yaml' do
    file = load_fixture('glide.yaml')

    expect(Bibliothecary::Parsers::Go.analyse_file('glide.yaml', file, 'glide.yaml')).to eq({
      :platform=>"go",
      :path=>"glide.yaml",
      :dependencies=>[
        {:name=>"gopkg.in/yaml.v2", :requirement=>"*", :type=>"runtime"},
        {:name=>"github.com/Masterminds/vcs",
         :requirement=>"^1.4.0",
         :type=>"runtime"},
        {:name=>"github.com/codegangsta/cli", :requirement=>"*", :type=>"runtime"},
        {:name=>"github.com/Masterminds/semver",
         :requirement=>"^1.0.0",
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from glide.lock' do
    file = load_fixture('glide.lock')

    expect(Bibliothecary::Parsers::Go.analyse_file('glide.lock', file, 'glide.lock')).to eq({
      :platform=>"go",
      :path=>"glide.lock",
      :dependencies=>[
        {:name=>"github.com/codegangsta/cli",
         :requirement=>"c31a7975863e7810c92e2e288a9ab074f9a88f29",
         :type=>"runtime"},
        {:name=>"github.com/Masterminds/semver",
         :requirement=>"513f3dcb3ecfb1248831fb5cb06a23a3cd5935dc",
         :type=>"runtime"},
        {:name=>"github.com/Masterminds/vcs",
         :requirement=>"9c0db6583837118d5df7c2ae38ab1c194e434b35",
         :type=>"runtime"},
        {:name=>"gopkg.in/yaml.v2",
         :requirement=>"f7716cbe52baa25d2e9b0d0da546fcf909fc16b4",
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from Godeps.json' do
    file = load_fixture('Godeps.json')

    expect(Bibliothecary::Parsers::Go.analyse_file('Godeps/Godeps.json', file, 'Godeps/Godeps.json')).to eq({
      :platform=>"go",
      :path=>"Godeps/Godeps.json",
      :dependencies=>[
        {:name=>"github.com/BurntSushi/toml",
         :requirement=>"3883ac1ce943878302255f538fce319d23226223",
         :type=>"runtime"},
        {:name=>"github.com/Sirupsen/logrus",
         :requirement=>"418b41d23a1bf978c06faea5313ba194650ac088",
         :type=>"runtime"},
        {:name=>"github.com/ayufan/golang-kardianos-service",
         :requirement=>"9ce7ccf10c81705a8880170bbf506bd539bc69b2",
         :type=>"runtime"},
        {:name=>"github.com/codegangsta/cli",
         :requirement=>"142e6cd241a4dfbf7f07a018f1f8225180018da4",
         :type=>"runtime"},
        {:name=>"github.com/fsouza/go-dockerclient",
         :requirement=>"163268693e2cf8be2920158b59ef438fc77b85e2",
         :type=>"runtime"},
        {:name=>"github.com/golang/mock/gomock",
         :requirement=>"06883d979f10cc178f2716846215c8cf90f9e363",
         :type=>"runtime"},
        {:name=>"github.com/kardianos/osext",
         :requirement=>"efacde03154693404c65e7aa7d461ac9014acd0c",
         :type=>"runtime"},
        {:name=>"github.com/ramr/go-reaper",
         :requirement=>"1a6cbc07ef2f7e248769ef4efd80aaa16f97ec12",
         :type=>"runtime"},
        {:name=>"github.com/stretchr/objx",
         :requirement=>"cbeaeb16a013161a98496fad62933b1d21786672",
         :type=>"runtime"},
        {:name=>"github.com/stretchr/testify/assert",
         :requirement=>"1297dc01ed0a819ff634c89707081a4df43baf6b",
         :type=>"runtime"},
        {:name=>"github.com/stretchr/testify/mock",
         :requirement=>"1297dc01ed0a819ff634c89707081a4df43baf6b",
         :type=>"runtime"},
        {:name=>"gitlab.com/ayufan/golang-cli-helpers",
         :requirement=>"0a14b63a7466ee44de4a90f998fad73afa8482bf",
         :type=>"runtime"},
        {:name=>"golang.org/x/crypto/ssh",
         :requirement=>"1351f936d976c60a0a48d728281922cf63eafb8d",
         :type=>"runtime"},
        {:name=>"gopkg.in/yaml.v1",
         :requirement=>"9f9df34309c04878acc86042b16630b0f696e1de",
         :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from gb_manifest' do
    file = load_fixture('gb_manifest')

    expect(Bibliothecary::Parsers::Go.analyse_file('vendor/manifest', file, 'vendor/manifest')).to eq({
      :platform=>"go",
      :path=>"vendor/manifest",
      :dependencies=>[
        {:name=>"github.com/gorilla/mux",
         :requirement=>"9fa818a44c2bf1396a17f9d5a3c0f6dd39d2ff8e",
         :type=>"runtime"}
      ]
    })
  end
end
