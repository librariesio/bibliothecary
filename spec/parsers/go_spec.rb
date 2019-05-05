require 'spec_helper'

describe Bibliothecary::Parsers::Go do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('go')
  end

  it 'parses depenencies from go.mod' do
    expect(described_class.analyse_contents('go.mod', load_fixture('go.mod'))).to eq({
      :platform=>"go",
      :path=>"go.mod",
      :dependencies=>[
        {:name=>"github.com/go-check/check",
         :requirement=>"v0.0.0-20180628173108-788fd7840127",
         :type=>"runtime"},
        {:name=>"github.com/gomodule/redigo",
         :requirement=>"v2.0.0+incompatible",
         :type=>"runtime"}
        {:name=>"github.com/kr/pretty",
         :requirement=>"v0.1.0",
         :type=>"runtime"}
        {:name=>"github.com/replicon/fast-archiver",
         :requirement=>"v0.0.0-20121220195659-060bf9adec25",
         :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses depenencies from go.sum' do
    expect(described_class.analyse_contents('go.sum', load_fixture('go.sum'))).to eq({
      :platform=>"go",
      :path=>"go.sum",
      :dependencies=>[
        {:name=>"github.com/go-check/check",
         :requirement=>"v0.0.0-20180628173108-788fd7840127",
         :type=>"runtime"},
        {:name=>"github.com/gomodule/redigo",
         :requirement=>"v2.0.0+incompatible",
         :type=>"runtime"},
        {:name=>"github.com/kr/pretty",
         :requirement=>"v0.1.0",
         :type=>"runtime"},
        {:name=>"github.com/kr/pty",
         :requirement=>"v0.1.0",
         :type=>"runtime"},
        {:name=>"github.com/kr/text",
         :requirement=>"v0.1.0",
         :type=>"runtime"},
        {:name=>"github.com/replicon/fast-archiver",
         :requirement=>"v0.0.0-20121220195659-060bf9adec25",
         :type=>"runtime"}
      ],
      kind: 'checksum',
      success: true
    })
  end

  it 'parses dependencies from glide.yaml' do
    expect(described_class.analyse_contents('glide.yaml', load_fixture('glide.yaml'))).to eq({
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
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from glide.lock' do
    expect(described_class.analyse_contents('glide.lock', load_fixture('glide.lock'))).to eq({
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
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from Godeps.json' do
    expect(described_class.analyse_contents('Godeps/Godeps.json', load_fixture('Godeps.json'))).to eq({
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
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from gb_manifest' do
    expect(described_class.analyse_contents('vendor/manifest', load_fixture('gb_manifest'))).to eq({
      :platform=>"go",
      :path=>"vendor/manifest",
      :dependencies=>[
        {:name=>"github.com/gorilla/mux",
         :requirement=>"9fa818a44c2bf1396a17f9d5a3c0f6dd39d2ff8e",
         :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from gpm Godep file' do
    expect(described_class.analyse_contents('Godeps', load_fixture('Godeps'))).to eq({
      :platform=>"go",
      :path=>"Godeps",
      :dependencies=>[
        {:name=>"github.com/nu7hatch/gotrail", :requirement=>"v0.0.2", :type=>"runtime"},
        {:name=>"github.com/replicon/fast-archiver", :requirement=>"v1.02", :type=>"runtime"},
        {:name=>"github.com/garyburd/redigo/redis", :requirement=>"a6a0a737c00caf4d4c2bb589941ace0d688168bb", :type=>"runtime"},
        {:name=>"launchpad.net/gocheck", :requirement=>"r2013.03.03", :type=>"runtime"},
        {:name=>"code.google.com/p/go.example/hello/...", :requirement=>"ae081cd1d6cc", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from govendor vendor.json file' do
    expect(described_class.analyse_contents('vendor/vendor.json', load_fixture('vendor.json'))).to eq({
      :platform=>"go",
      :path=>"vendor/vendor.json",
      :dependencies=>[
        {:name=>"github.com/Bowery/prompt", :requirement=>"d43c2707a6c5a152a344c64bb4fed657e2908a81", :type=>"runtime"},
        {:name=>"github.com/dchest/safefile", :requirement=>"855e8d98f1852d48dde521e0522408d1fe7e836a", :type=>"runtime"},
        {:name=>"github.com/google/shlex", :requirement=>"6f45313302b9c56850fc17f99e40caebce98c716", :type=>"runtime"},
        {:name=>"github.com/pkg/errors", :requirement=>"a2d6902c6d2a2f194eb3fb474981ab7867c81505", :type=>"runtime"},
        {:name=>"golang.org/x/tools/go/vcs", :requirement=>"1727758746e7a08feaaceb9366d1468498ac2ac2", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from dep Gopkg.toml file' do
    expect(described_class.analyse_contents('Gopkg.toml', load_fixture('Gopkg.toml'))).to eq({
      :platform=>"go",
      :path=>"Gopkg.toml",
      :dependencies=>[
        {:name=>"github.com/Masterminds/semver", :requirement=>"*", :type=>"runtime"},
        {:name=>"github.com/Masterminds/vcs", :requirement=>"1.11.0", :type=>"runtime"},
        {:name=>"github.com/go-yaml/yaml", :requirement=>"*", :type=>"runtime"},
        {:name=>"github.com/pelletier/go-toml", :requirement=>"*", :type=>"runtime"},
        {:name=>"github.com/pkg/errors", :requirement=>"0.8.0", :type=>"runtime"},
        {:name=>"github.com/boltdb/bolt", :requirement=>"1.0.0", :type=>"runtime"},
        {:name=>"github.com/jmank88/nuts", :requirement=>"0.2.0", :type=>"runtime"},
        {:name=>"github.com/golang/protobuf", :requirement=>"*", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from dep Gopkg.lock file' do
    expect(described_class.analyse_contents('Gopkg.lock', load_fixture('Gopkg.lock'))).to eq({
      :platform=>"go",
      :path=>"Gopkg.lock",
      :dependencies=>[
        {:name=>"github.com/Masterminds/semver", :requirement=>"a93e51b5a57ef416dac8bb02d11407b6f55d8929", :type=>"runtime"},
        {:name=>"github.com/Masterminds/vcs", :requirement=>"3084677c2c188840777bff30054f2b553729d329", :type=>"runtime"},
        {:name=>"github.com/armon/go-radix", :requirement=>"4239b77079c7b5d1243b7b4736304ce8ddb6f0f2", :type=>"runtime"},
        {:name=>"github.com/boltdb/bolt", :requirement=>"2f1ce7a837dcb8da3ec595b1dac9d0632f0f99e8", :type=>"runtime"},
        {:name=>"github.com/go-yaml/yaml", :requirement=>"cd8b52f8269e0feb286dfeef29f8fe4d5b397e0b", :type=>"runtime"},
        {:name=>"github.com/golang/protobuf", :requirement=>"5afd06f9d81a86d6e3bb7dc702d6bd148ea3ff23", :type=>"runtime"},
        {:name=>"github.com/jmank88/nuts", :requirement=>"a1e02c788669d022c325a8ee674f15360d7104f4", :type=>"runtime"},
        {:name=>"github.com/nightlyone/lockfile", :requirement=>"e83dc5e7bba095e8d32fb2124714bf41f2a30cb5", :type=>"runtime"},
        {:name=>"github.com/pelletier/go-toml", :requirement=>"b8b5e7696574464b2f9bf303a7b37781bb52889f", :type=>"runtime"},
        {:name=>"github.com/pkg/errors", :requirement=>"645ef00459ed84a119197bfb8d8205042c6df63d", :type=>"runtime"},
        {:name=>"github.com/sdboyer/constext", :requirement=>"836a144573533ea4da4e6929c235fd348aed1c80", :type=>"runtime"},
        {:name=>"golang.org/x/net", :requirement=>"66aacef3dd8a676686c7ae3716979581e8b03c47", :type=>"runtime"},
        {:name=>"golang.org/x/sync", :requirement=>"f52d1811a62927559de87708c8913c1650ce4f26", :type=>"runtime"},
        {:name=>"golang.org/x/sys", :requirement=>"bb24a47a89eac6c1227fbcb2ae37a8b9ed323366", :type=>"runtime"}
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('go.mod')).to be_truthy
    expect(described_class.match?('go.sum')).to be_truthy
    expect(described_class.match?('Godeps/Godeps.json')).to be_truthy
    expect(described_class.match?('vendor/manifest')).to be_truthy
    expect(described_class.match?('glide.yaml')).to be_truthy
    expect(described_class.match?('glide.lock')).to be_truthy
    expect(described_class.match?('Godeps')).to be_truthy
    expect(described_class.match?('vendor/vendor.json')).to be_truthy
    expect(described_class.match?('Gopkg.toml')).to be_truthy
    expect(described_class.match?('Gopkg.lock')).to be_truthy
  end
end
