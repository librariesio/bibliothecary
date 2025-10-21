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

  it "parses dependencies from *.cabal files", :vcr do
    stub_request(:post, "http://cabal.libraries.io/parse").
      with(
        body: load_fixture("example.cabal"),
        headers: {'Content-Type'=>'text/plain;charset=utf-8', 'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate([
        {name: "aeson", requirement: "==1.1.*", type: "runtime"},
        {name: "base", requirement: ">=4.9 && <4.11", type: "runtime"},
        {name: "Cabal", requirement: "==2.0.*", type: "runtime"},
        {name: "envy", requirement: "==1.3.*", type: "runtime"},
        {name: "pretty", requirement: "==1.1.*", type: "runtime"},
        {name: "servant-server", requirement: "==0.11.*", type: "runtime"},
        {name: "text", requirement: "==1.2.*", type: "runtime"},
        {name: "utf8-string", requirement: "==1.0.*", type: "runtime"},
        {name: "warp", requirement: "==3.2.*", type: "runtime"},
        {name: "hspec-discover", requirement: "==2.4.*", type: "build"},
        {name: "aeson", requirement: "==1.1.*", type: "test"},
        {name: "base", requirement: ">=4.9 && <4.11", type: "test"},
        {name: "bytestring", requirement: "==0.10.*", type: "test"},
        {name: "Cabal", requirement: "==2.0.*", type: "test"},
        {name: "hspec", requirement: "==2.4.*", type: "test"},
        {name: "pretty", requirement: "==1.1.*", type: "test"},
        {name: "text", requirement: "==1.2.*", type: "test"}
      ]), headers: {})

    expect(described_class.analyse_contents("example.cabal", load_fixture("example.cabal"))).to eq({
      platform: "hackage",
      path: "example.cabal",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hackage", name: "aeson", requirement: "==1.1.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "base", requirement: ">=4.9 && <4.11", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "Cabal", requirement: "==2.0.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "envy", requirement: "==1.3.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "pretty", requirement: "==1.1.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "servant-server", requirement: "==0.11.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "text", requirement: "==1.2.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "utf8-string", requirement: "==1.0.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "warp", requirement: "==3.2.*", type: "runtime", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "hspec-discover", requirement: "==2.4.*", type: "build", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "aeson", requirement: "==1.1.*", type: "test", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "base", requirement: ">=4.9 && <4.11", type: "test", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "bytestring", requirement: "==0.10.*", type: "test", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "Cabal", requirement: "==2.0.*", type: "test", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "hspec", requirement: "==2.4.*", type: "test", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "pretty", requirement: "==1.1.*", type: "test", source: "example.cabal"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "text", requirement: "==1.2.*", type: "test", source: "example.cabal"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from cabal.config files" do
    expect(described_class.analyse_contents("cabal.config", load_fixture("cabal.config"))).to eq({
      platform: "hackage",
      path: "cabal.config",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hackage", name: "Cabal", requirement: "2.0.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "aeson", requirement: "1.1.2.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "ansi-terminal", requirement: "0.8", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "ansi-wl-pprint", requirement: "0.6.8.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "appar", requirement: "0.1.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "array", requirement: "0.5.2.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "async", requirement: "2.1.1.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "attoparsec", requirement: "0.13.2.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "attoparsec-iso8601", requirement: "1.0.0.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "auto-update", requirement: "0.1.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "base", requirement: "4.10.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "base-compat", requirement: "0.9.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "base64-bytestring", requirement: "1.0.0.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "basement", requirement: "0.0.5", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "binary", requirement: "0.8.5.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "blaze-builder", requirement: "0.4.0.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "blaze-html", requirement: "0.9.0.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "blaze-markup", requirement: "0.8.2.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "byteorder", requirement: "1.0.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "bytestring", requirement: "0.10.8.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "bytestring-builder", requirement: "0.10.8.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "case-insensitive", requirement: "1.2.0.10", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "colour", requirement: "2.3.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "containers", requirement: "0.5.10.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "cookie", requirement: "0.4.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "cryptonite", requirement: "0.24", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "data-default-class", requirement: "0.1.2.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "deepseq", requirement: "1.4.3.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "directory", requirement: "1.3.0.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "dlist", requirement: "0.8.0.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "easy-file", requirement: "0.2.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "envy", requirement: "1.3.0.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "exceptions", requirement: "0.8.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "fail", requirement: "4.9.0.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "fast-logger", requirement: "2.4.10", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "file-embed", requirement: "0.0.10.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "filepath", requirement: "1.4.1.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "foundation", requirement: "0.0.18", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "ghc-boot-th", requirement: "8.2.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "ghc-prim", requirement: "0.5.1.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "hashable", requirement: "1.2.6.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "http-api-data", requirement: "0.3.7.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "http-date", requirement: "0.0.6.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "http-media", requirement: "0.7.1.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "http-types", requirement: "0.10", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "http2", requirement: "1.6.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "integer-gmp", requirement: "1.0.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "integer-logarithms", requirement: "1.0.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "iproute", requirement: "1.7.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "lifted-base", requirement: "0.2.3.11", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "memory", requirement: "0.14.12", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "mime-types", requirement: "0.1.0.7", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "mmorph", requirement: "1.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "monad-control", requirement: "1.0.2.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "mtl", requirement: "2.2.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "natural-transformation", requirement: "0.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "network", requirement: "2.6.3.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "network-uri", requirement: "2.6.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "old-locale", requirement: "1.0.0.7", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "old-time", requirement: "1.1.0.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "optparse-applicative", requirement: "0.14.0.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "parsec", requirement: "3.1.11", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "pretty", requirement: "1.1.3.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "primitive", requirement: "0.6.2.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "process", requirement: "1.6.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "psqueues", requirement: "0.2.4.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "random", requirement: "1.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "resourcet", requirement: "1.1.11", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "rts", requirement: "1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "safe", requirement: "0.3.16", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "scientific", requirement: "0.3.5.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "servant", requirement: "0.11", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "servant-server", requirement: "0.11.0.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "simple-sendfile", requirement: "0.2.26", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "split", requirement: "0.2.3.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "stm", requirement: "2.4.4.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "streaming-commons", requirement: "0.1.18", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "string-conversions", requirement: "0.4.0.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "stringsearch", requirement: "0.3.6.6", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "system-filepath", requirement: "0.4.13.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "tagged", requirement: "0.8.5", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "template-haskell", requirement: "2.12.0.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "text", requirement: "1.2.3.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "th-lift", requirement: "0.7.7", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "th-lift-instances", requirement: "0.1.11", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "time", requirement: "1.8.0.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "time-locale-compat", requirement: "0.1.1.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "transformers", requirement: "0.5.2.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "transformers-base", requirement: "0.4.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "transformers-compat", requirement: "0.5.1.4", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "unix", requirement: "2.7.2.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "unix-compat", requirement: "0.5.0.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "unix-time", requirement: "0.3.7", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "unliftio-core", requirement: "0.1.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "unordered-containers", requirement: "0.2.8.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "uri-bytestring", requirement: "0.3.1.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "utf8-string", requirement: "1.0.1.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "uuid-types", requirement: "1.0.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "vault", requirement: "0.3.0.7", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "vector", requirement: "0.12.0.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "void", requirement: "0.7.2", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "wai", requirement: "3.2.1.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "wai-app-static", requirement: "3.1.6.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "wai-extra", requirement: "3.0.21.0", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "wai-logger", requirement: "2.3.1", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "warp", requirement: "3.2.13", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "word8", requirement: "0.1.3", type: "runtime", source: "cabal.config"),
        Bibliothecary::Dependency.new(platform: "hackage", name: "zlib", requirement: "0.6.1.2", type: "runtime", source: "cabal.config"),
      ],
      kind: "lockfile",
      project_name: nil,
      success: true,
    })
  end
end
