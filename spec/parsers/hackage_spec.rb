require "spec_helper"

describe Bibliothecary::Parsers::Hackage do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("hackage")
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("cabal-parser.cabal")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("cabal.nix")).to be_falsey
    expect(described_class.match?("cabal-parser.nix")).to be_falsey
    expect(described_class.match?("cabal.sandbox.config")).to be_falsey
    expect(described_class.match?("ChangeLog.md")).to be_falsey
    expect(described_class.match?("CODE_OF_CONDUCT.md")).to be_falsey
    expect(described_class.match?("default.nix")).to be_falsey
    expect(described_class.match?("dist")).to be_falsey
    expect(described_class.match?("docker-compose.yml")).to be_falsey
    expect(described_class.match?("Dockerfile")).to be_falsey
    expect(described_class.match?("LICENSE")).to be_falsey
    expect(described_class.match?("README.md")).to be_falsey
    expect(described_class.match?("Setup.hs")).to be_falsey
    expect(described_class.match?("shell.nix")).to be_falsey
    expect(described_class.match?("src")).to be_falsey
    expect(described_class.match?("test")).to be_falsey
  end

  it 'parses dependencies from *.cabal files', :vcr do
    expect(described_class.analyse_contents('example.cabal', load_fixture('example.cabal'))).to eq({
      platform: "hackage",
      path: "example.cabal",
      dependencies: [
        { requirement: "==1.1.*", name: "aeson", type: "runtime" },
        { requirement: ">=4.9 && <4.11", name: "base", type: "runtime" },
        { requirement: "==2.0.*", name: "Cabal", type: "runtime" },
        { requirement: "==1.3.*", name: "envy", type: "runtime" },
        { requirement: "==1.1.*", name: "pretty", type: "runtime" },
        { requirement: "==0.11.*", name: "servant-server", type: "runtime" },
        { requirement: "==1.2.*", name: "text", type: "runtime" },
        { requirement: "==1.0.*", name: "utf8-string", type: "runtime" },
        { requirement: "==3.2.*", name: "warp", type: "runtime" },
        { requirement: "==2.4.*", name: "hspec-discover", type: "build" },
        { requirement: "==1.1.*", name: "aeson", type: "test" },
        { requirement: ">=4.9 && <4.11", name: "base", type: "test" },
        { requirement: "==0.10.*", name: "bytestring", type: "test" },
        { requirement: "==2.0.*", name: "Cabal", type: "test" },
        { requirement: "==2.4.*", name: "hspec", type: "test" },
        { requirement: "==1.1.*", name: "pretty", type: "test" },
        { requirement: "==1.2.*", name: "text", type: "test" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from cabal.config files' do
    expect(described_class.analyse_contents('cabal.config', load_fixture('cabal.config'))).to eq({
      platform: "hackage",
      path: "cabal.config",
      dependencies: [
        { name: "Cabal", requirement: "2.0.1.0", type: "runtime" },
        { name: "aeson", requirement: "1.1.2.0", type: "runtime" },
        { name: "ansi-terminal", requirement: "0.8", type: "runtime" },
        { name: "ansi-wl-pprint", requirement: "0.6.8.2", type: "runtime" },
        { name: "appar", requirement: "0.1.4", type: "runtime" },
        { name: "array", requirement: "0.5.2.0", type: "runtime" },
        { name: "async", requirement: "2.1.1.1", type: "runtime" },
        { name: "attoparsec", requirement: "0.13.2.2", type: "runtime" },
        { name: "attoparsec-iso8601", requirement: "1.0.0.0", type: "runtime" },
        { name: "auto-update", requirement: "0.1.4", type: "runtime" },
        { name: "base", requirement: "4.10.1.0", type: "runtime" },
        { name: "base-compat", requirement: "0.9.3", type: "runtime" },
        { name: "base64-bytestring", requirement: "1.0.0.1", type: "runtime" },
        { name: "basement", requirement: "0.0.5", type: "runtime" },
        { name: "binary", requirement: "0.8.5.1", type: "runtime" },
        { name: "blaze-builder", requirement: "0.4.0.2", type: "runtime" },
        { name: "blaze-html", requirement: "0.9.0.1", type: "runtime" },
        { name: "blaze-markup", requirement: "0.8.2.0", type: "runtime" },
        { name: "byteorder", requirement: "1.0.4", type: "runtime" },
        { name: "bytestring", requirement: "0.10.8.2", type: "runtime" },
        { name: "bytestring-builder", requirement: "0.10.8.1.0", type: "runtime" },
        { name: "case-insensitive", requirement: "1.2.0.10", type: "runtime" },
        { name: "colour", requirement: "2.3.4", type: "runtime" },
        { name: "containers", requirement: "0.5.10.2", type: "runtime" },
        { name: "cookie", requirement: "0.4.3", type: "runtime" },
        { name: "cryptonite", requirement: "0.24", type: "runtime" },
        { name: "data-default-class", requirement: "0.1.2.0", type: "runtime" },
        { name: "deepseq", requirement: "1.4.3.0", type: "runtime" },
        { name: "directory", requirement: "1.3.0.2", type: "runtime" },
        { name: "dlist", requirement: "0.8.0.3", type: "runtime" },
        { name: "easy-file", requirement: "0.2.1", type: "runtime" },
        { name: "envy", requirement: "1.3.0.2", type: "runtime" },
        { name: "exceptions", requirement: "0.8.3", type: "runtime" },
        { name: "fail", requirement: "4.9.0.0", type: "runtime" },
        { name: "fast-logger", requirement: "2.4.10", type: "runtime" },
        { name: "file-embed", requirement: "0.0.10.1", type: "runtime" },
        { name: "filepath", requirement: "1.4.1.2", type: "runtime" },
        { name: "foundation", requirement: "0.0.18", type: "runtime" },
        { name: "ghc-boot-th", requirement: "8.2.2", type: "runtime" },
        { name: "ghc-prim", requirement: "0.5.1.1", type: "runtime" },
        { name: "hashable", requirement: "1.2.6.1", type: "runtime" },
        { name: "http-api-data", requirement: "0.3.7.1", type: "runtime" },
        { name: "http-date", requirement: "0.0.6.1", type: "runtime" },
        { name: "http-media", requirement: "0.7.1.1", type: "runtime" },
        { name: "http-types", requirement: "0.10", type: "runtime" },
        { name: "http2", requirement: "1.6.3", type: "runtime" },
        { name: "integer-gmp", requirement: "1.0.1.0", type: "runtime" },
        { name: "integer-logarithms", requirement: "1.0.2", type: "runtime" },
        { name: "iproute", requirement: "1.7.1", type: "runtime" },
        { name: "lifted-base", requirement: "0.2.3.11", type: "runtime" },
        { name: "memory", requirement: "0.14.12", type: "runtime" },
        { name: "mime-types", requirement: "0.1.0.7", type: "runtime" },
        { name: "mmorph", requirement: "1.1.0", type: "runtime" },
        { name: "monad-control", requirement: "1.0.2.2", type: "runtime" },
        { name: "mtl", requirement: "2.2.1", type: "runtime" },
        { name: "natural-transformation", requirement: "0.4", type: "runtime" },
        { name: "network", requirement: "2.6.3.3", type: "runtime" },
        { name: "network-uri", requirement: "2.6.1.0", type: "runtime" },
        { name: "old-locale", requirement: "1.0.0.7", type: "runtime" },
        { name: "old-time", requirement: "1.1.0.3", type: "runtime" },
        { name: "optparse-applicative", requirement: "0.14.0.0", type: "runtime" },
        { name: "parsec", requirement: "3.1.11", type: "runtime" },
        { name: "pretty", requirement: "1.1.3.3", type: "runtime" },
        { name: "primitive", requirement: "0.6.2.0", type: "runtime" },
        { name: "process", requirement: "1.6.1.0", type: "runtime" },
        { name: "psqueues", requirement: "0.2.4.0", type: "runtime" },
        { name: "random", requirement: "1.1", type: "runtime" },
        { name: "resourcet", requirement: "1.1.11", type: "runtime" },
        { name: "rts", requirement: "1.0", type: "runtime" },
        { name: "safe", requirement: "0.3.16", type: "runtime" },
        { name: "scientific", requirement: "0.3.5.2", type: "runtime" },
        { name: "servant", requirement: "0.11", type: "runtime" },
        { name: "servant-server", requirement: "0.11.0.1", type: "runtime" },
        { name: "simple-sendfile", requirement: "0.2.26", type: "runtime" },
        { name: "split", requirement: "0.2.3.2", type: "runtime" },
        { name: "stm", requirement: "2.4.4.1", type: "runtime" },
        { name: "streaming-commons", requirement: "0.1.18", type: "runtime" },
        { name: "string-conversions", requirement: "0.4.0.1", type: "runtime" },
        { name: "stringsearch", requirement: "0.3.6.6", type: "runtime" },
        { name: "system-filepath", requirement: "0.4.13.4", type: "runtime" },
        { name: "tagged", requirement: "0.8.5", type: "runtime" },
        { name: "template-haskell", requirement: "2.12.0.0", type: "runtime" },
        { name: "text", requirement: "1.2.3.0", type: "runtime" },
        { name: "th-lift", requirement: "0.7.7", type: "runtime" },
        { name: "th-lift-instances", requirement: "0.1.11", type: "runtime" },
        { name: "time", requirement: "1.8.0.2", type: "runtime" },
        { name: "time-locale-compat", requirement: "0.1.1.3", type: "runtime" },
        { name: "transformers", requirement: "0.5.2.0", type: "runtime" },
        { name: "transformers-base", requirement: "0.4.4", type: "runtime" },
        { name: "transformers-compat", requirement: "0.5.1.4", type: "runtime" },
        { name: "unix", requirement: "2.7.2.2", type: "runtime" },
        { name: "unix-compat", requirement: "0.5.0.1", type: "runtime" },
        { name: "unix-time", requirement: "0.3.7", type: "runtime" },
        { name: "unliftio-core", requirement: "0.1.1.0", type: "runtime" },
        { name: "unordered-containers", requirement: "0.2.8.0", type: "runtime" },
        { name: "uri-bytestring", requirement: "0.3.1.0", type: "runtime" },
        { name: "utf8-string", requirement: "1.0.1.1", type: "runtime" },
        { name: "uuid-types", requirement: "1.0.3", type: "runtime" },
        { name: "vault", requirement: "0.3.0.7", type: "runtime" },
        { name: "vector", requirement: "0.12.0.1", type: "runtime" },
        { name: "void", requirement: "0.7.2", type: "runtime" },
        { name: "wai", requirement: "3.2.1.1", type: "runtime" },
        { name: "wai-app-static", requirement: "3.1.6.1", type: "runtime" },
        { name: "wai-extra", requirement: "3.0.21.0", type: "runtime" },
        { name: "wai-logger", requirement: "2.3.1", type: "runtime" },
        { name: "warp", requirement: "3.2.13", type: "runtime" },
        { name: "word8", requirement: "0.1.3", type: "runtime" },
        { name: "zlib", requirement: "0.6.1.2", type: "runtime" }
      ],
      kind: 'lockfile',
      success: true
    })
  end
end
