require "spec_helper"

describe Bibliothecary::Parsers::NPM do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("npm")
  end

  it_behaves_like "CycloneDX"

  it "doesn't group dependencies.csv with other files" do
    result = Bibliothecary.find_manifests_from_paths([
        "spec/fixtures/package.json",
        "spec/fixtures/package-lock.json",
        "spec/fixtures/dependencies.csv",
    ]).find_all { |r| r.platform == "npm" }

    expect(result.length).to eq(2)

    expect(
      result.find do |r|
        r.manifests == ["spec/fixtures/package.json"] &&
        r.lockfiles == ["spec/fixtures/package-lock.json"]
      end
    ).not_to eq(nil)

    expect(
      result.find do |r|
        r.manifests == [] &&
        r.lockfiles == ["spec/fixtures/dependencies.csv"]
      end
    ).not_to eq(nil)
  end

  it "parses dependencies from npm-ls.json" do
    expect(described_class.analyse_contents("npm-ls.json", load_fixture("npm-ls.json"))).to eq({
      platform: "npm",
      path: "npm-ls.json",
      dependencies: [
        Bibliothecary::Dependency.new( name: "ansicolor", requirement: "1.1.93", type: "runtime"),
        Bibliothecary::Dependency.new(name: "babel-cli", requirement: "6.26.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "debug", requirement: "2.6.9", type: "runtime"),
        Bibliothecary::Dependency.new(name:"babel-polyfill", requirement: "6.26.0", type: "runtime"),
        Bibliothecary::Dependency.new(name:"core-js", requirement: "2.6.12", type: "runtime"),
        Bibliothecary::Dependency.new(name:"lodash", requirement: "4.17.21", type: "runtime"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses dependencies from package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("package.json"))).to eq({
      platform: "npm",
      path: "package.json",
      dependencies: [
        Bibliothecary::Dependency.new(name: "babel", requirement: "^4.6.6", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "mocha", requirement: "^2.2.1", type: "development", local: false),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from npm-shrinkwrap.json" do
    expect(described_class.analyse_contents("npm-shrinkwrap.json", load_fixture("npm-shrinkwrap.json"))).to include({
      platform: "npm",
      path: "npm-shrinkwrap.json",
      kind: "lockfile",
      success: true,
    })
    expect(described_class.analyse_contents("npm-shrinkwrap.json", load_fixture("npm-shrinkwrap.json"))[:dependencies]).to include(
      Bibliothecary::Dependency.new(name:"babel", requirement:"4.7.16", type:"runtime"),
      Bibliothecary::Dependency.new(name:"body-parser", requirement:"1.13.3", type:"runtime"),
      Bibliothecary::Dependency.new(name:"bugsnag", requirement:"1.6.5", type:"runtime"),
      Bibliothecary::Dependency.new(name:"cookie-session", requirement:"1.2.0", type:"runtime"),
      Bibliothecary::Dependency.new(name:"debug", requirement:"2.2.0", type:"development"),
      Bibliothecary::Dependency.new(name:"deep-diff", requirement:"0.3.2", type:"runtime"),
      Bibliothecary::Dependency.new(name:"deep-equal", requirement:"1.0.0", type:"runtime"),
      Bibliothecary::Dependency.new(name:"express", requirement:"4.13.3", type:"runtime"),
      Bibliothecary::Dependency.new(name:"express-session", requirement:"1.11.3", type:"runtime"),
      Bibliothecary::Dependency.new(name:"jade", requirement:"1.11.0", type:"runtime"),
      Bibliothecary::Dependency.new(name:"js-yaml", requirement:"3.4.0", type:"runtime"),
      Bibliothecary::Dependency.new(name:"memwatch-next", requirement:"0.2.9", type:"runtime"),
      Bibliothecary::Dependency.new(name:"multer", requirement:"0.1.8", type:"runtime"),
      Bibliothecary::Dependency.new(name:"qs", requirement:"2.4.2", type:"runtime"),
      Bibliothecary::Dependency.new(name:"redis", requirement:"0.12.1", type:"runtime"),
      Bibliothecary::Dependency.new(name:"semver", requirement:"4.3.6", type:"runtime"),
      Bibliothecary::Dependency.new(name:"serve-static", requirement:"1.10.0", type:"runtime"),
      Bibliothecary::Dependency.new(name:"toml", requirement:"2.3.0", type:"runtime"),
    )
  end

  it "parses dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn.lock"))).to eq({
      platform: "npm",
      path: "yarn.lock",
      dependencies: [
        Bibliothecary::Dependency.new(name: "body-parser", requirement: "1.16.1", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "bytes", requirement: "2.4.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "content-type", requirement: "1.0.2", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "debug", requirement: "2.6.1", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "depd", requirement: "1.1.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "ee-first", requirement: "1.1.1", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "http-errors", requirement: "1.5.1", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "iconv-lite", requirement: "0.4.15", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "inherits", requirement: "2.0.3", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "media-typer", requirement: "0.3.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "mime-db", requirement: "1.26.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "mime-types", requirement: "2.1.14", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "ms", requirement: "0.7.2", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "on-finished", requirement: "2.3.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "qs", requirement: "6.2.1", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "raw-body", requirement: "2.2.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "setprototypeof", requirement: "1.0.2", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "statuses", requirement: "1.3.1", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "type-is", requirement: "1.6.14", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "unpipe", requirement: "1.0.0", type: "runtime", local: false),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses git dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn-with-git-repo/yarn.lock"))).to eq({
      platform: "npm",
      path: "yarn.lock",
      dependencies: [
        Bibliothecary::Dependency.new(name: "vue", requirement: "2.6.12", type: "runtime", local: false),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses git dependencies from package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("yarn-with-git-repo/package.json"))).to eq({
      platform: "npm",
      path: "package.json",
      dependencies: [
        Bibliothecary::Dependency.new(name: "vue", requirement: "https://github.com/vuejs/vue.git#v2.6.12", type: "runtime", local: false),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "wont load package-lock.json from a package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("package-lock.json"))).to match({
      platform: "npm",
      path: "package.json",
      dependencies: nil,
      kind: "manifest",
      success: false,
      error_message: "package.json: appears to be a lockfile rather than manifest format",
      error_location: match("in `parse_manifest'"),
    })
  end

  it "parses dependencies from package-lock.json" do
    expect(described_class.analyse_contents("package-lock.json", load_fixture("package-lock.json"))).to eq({
      platform: "npm",
      path: "package-lock.json",
      dependencies: [
        Bibliothecary::Dependency.new(name: "accepts", requirement: "1.3.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ajv", requirement: "4.11.8", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ansi-escapes", requirement: "1.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ansi-regex", requirement: "2.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ansi-styles", requirement: "2.2.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "array-find-index", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "array-flatten", requirement: "1.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "asn1", requirement: "0.2.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "assert-plus", requirement: "0.2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "asynckit", requirement: "0.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "aws-sign2", requirement: "0.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "aws4", requirement: "1.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "babel-runtime", requirement: "6.23.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "balanced-match", requirement: "0.4.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "bcrypt-pbkdf", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "bl", requirement: "1.2.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "body-parser", requirement: "1.17.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "boom", requirement: "2.10.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "brace-expansion", requirement: "1.1.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "browserify-zlib", requirement: "0.1.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "buffer-shims", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "builtin-modules", requirement: "1.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "bytes", requirement: "2.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "camelcase", requirement: "4.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "caseless", requirement: "0.12.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "chalk", requirement: "1.1.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "chownr", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ci-info", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "cli-cursor", requirement: "2.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "cli-width", requirement: "2.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "cmd-shim", requirement: "2.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "co", requirement: "4.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "combined-stream", requirement: "1.0.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "commander", requirement: "2.9.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "concat-map", requirement: "0.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "content-disposition", requirement: "0.5.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "content-type", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "cookie", requirement: "0.3.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "cookie-signature", requirement: "1.0.6", type: "runtime"),
        Bibliothecary::Dependency.new(name: "core-js", requirement: "2.4.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "core-util-is", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "cryptiles", requirement: "2.0.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "currently-unhandled", requirement: "0.4.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "dashdash", requirement: "1.14.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "assert-plus", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "death", requirement: "1.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "debug", requirement: "2.6.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "delayed-stream", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "depd", requirement: "1.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "destroy", requirement: "1.0.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "detect-indent", requirement: "5.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "duplexify", requirement: "3.5.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ecc-jsbn", requirement: "0.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ee-first", requirement: "1.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "encodeurl", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "end-of-stream", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "escape-html", requirement: "1.0.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "escape-string-regexp", requirement: "1.0.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "etag", requirement: "1.8.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "express", requirement: "4.15.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "extend", requirement: "3.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "external-editor", requirement: "2.0.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "iconv-lite", requirement: "0.4.17", type: "runtime"),
        Bibliothecary::Dependency.new(name: "extsprintf", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "figures", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "finalhandler", requirement: "1.0.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "forever-agent", requirement: "0.6.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "form-data", requirement: "2.1.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "forwarded", requirement: "0.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "fresh", requirement: "0.5.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "fs.realpath", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "getpass", requirement: "0.1.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "assert-plus", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "glob", requirement: "7.1.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "graceful-fs", requirement: "4.1.11", type: "runtime"),
        Bibliothecary::Dependency.new(name: "graceful-readlink", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "gunzip-maybe", requirement: "1.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "har-schema", requirement: "1.0.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "har-validator", requirement: "4.2.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "has-ansi", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "hawk", requirement: "3.1.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "hoek", requirement: "2.16.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "http-errors", requirement: "1.6.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "http-signature", requirement: "1.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "iconv-lite", requirement: "0.4.15", type: "runtime"),
        Bibliothecary::Dependency.new(name: "inflight", requirement: "1.0.6", type: "runtime"),
        Bibliothecary::Dependency.new(name: "inherits", requirement: "2.0.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ini", requirement: "1.3.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "inquirer", requirement: "3.0.6", type: "runtime"),
        Bibliothecary::Dependency.new(name: "invariant", requirement: "2.2.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ipaddr.js", requirement: "1.3.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-builtin-module", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-ci", requirement: "1.0.10", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-deflate", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-fullwidth-code-point", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-gzip", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-promise", requirement: "2.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "is-typedarray", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "isarray", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "isstream", requirement: "0.1.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "jodid25519", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "js-tokens", requirement: "3.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "jsbn", requirement: "0.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "jschardet", requirement: "1.4.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "json-schema", requirement: "0.2.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "json-stable-stringify", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "json-stringify-safe", requirement: "5.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "jsonify", requirement: "0.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "jsprim", requirement: "1.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "assert-plus", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "leven", requirement: "2.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "lodash", requirement: "4.17.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "loose-envify", requirement: "1.3.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "loud-rejection", requirement: "1.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "media-typer", requirement: "0.3.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "merge-descriptors", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "methods", requirement: "1.1.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "mime", requirement: "1.3.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "mime-db", requirement: "1.27.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "mime-types", requirement: "2.1.15", type: "runtime"),
        Bibliothecary::Dependency.new(name: "mimic-fn", requirement: "1.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "minimatch", requirement: "3.0.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "minimist", requirement: "0.0.8", type: "runtime"),
        Bibliothecary::Dependency.new(name: "mkdirp", requirement: "0.5.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ms", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "mute-stream", requirement: "0.0.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "negotiator", requirement: "0.6.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "node-emoji", requirement: "1.5.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "oauth-sign", requirement: "0.8.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "object-path", requirement: "0.11.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "on-finished", requirement: "2.3.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "once", requirement: "1.3.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "onetime", requirement: "2.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "os-tmpdir", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "pako", requirement: "0.2.9", type: "runtime"),
        Bibliothecary::Dependency.new(name: "parseurl", requirement: "1.3.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "path-is-absolute", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "path-to-regexp", requirement: "0.1.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "peek-stream", requirement: "1.1.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "performance-now", requirement: "0.2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "process-nextick-args", requirement: "1.0.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "proper-lockfile", requirement: "2.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "proxy-addr", requirement: "1.1.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "pump", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "end-of-stream", requirement: "1.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "once", requirement: "1.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "pumpify", requirement: "1.3.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "punycode", requirement: "1.4.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "qs", requirement: "6.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "range-parser", requirement: "1.2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "raw-body", requirement: "2.2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "read", requirement: "1.0.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "readable-stream", requirement: "2.2.9", type: "runtime"),
        Bibliothecary::Dependency.new(name: "regenerator-runtime", requirement: "0.10.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "request", requirement: "2.81.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "request-capture-har", requirement: "1.2.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "restore-cursor", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "retry", requirement: "0.10.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rimraf", requirement: "2.6.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "run-async", requirement: "2.3.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "rx", requirement: "4.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "safe-buffer", requirement: "5.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "semver", requirement: "5.3.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "send", requirement: "0.15.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "serve-static", requirement: "1.12.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "setprototypeof", requirement: "1.0.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "signal-exit", requirement: "3.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "sntp", requirement: "1.0.9", type: "runtime"),
        Bibliothecary::Dependency.new(name: "spdx-correct", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "spdx-expression-parse", requirement: "1.0.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "spdx-license-ids", requirement: "1.2.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "sshpk", requirement: "1.13.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "assert-plus", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "statuses", requirement: "1.3.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "stream-shift", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "string_decoder", requirement: "1.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "string-width", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "string.prototype.codepointat", requirement: "0.2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "stringstream", requirement: "0.0.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "strip-ansi", requirement: "3.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "strip-bom", requirement: "3.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "supports-color", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tar-fs", requirement: "1.15.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tar-stream", requirement: "1.5.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "through", requirement: "2.3.8", type: "runtime"),
        Bibliothecary::Dependency.new(name: "through2", requirement: "2.0.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tmp", requirement: "0.0.31", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tough-cookie", requirement: "2.3.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tunnel-agent", requirement: "0.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "tweetnacl", requirement: "0.14.5", type: "runtime"),
        Bibliothecary::Dependency.new(name: "type-is", requirement: "1.6.15", type: "runtime"),
        Bibliothecary::Dependency.new(name: "unpipe", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "util-deprecate", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "utils-merge", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "uuid", requirement: "3.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "v8-compile-cache", requirement: "1.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "validate-npm-package-license", requirement: "3.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "vary", requirement: "1.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "verror", requirement: "1.3.6", type: "runtime"),
        Bibliothecary::Dependency.new(name: "wrappy", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "xtend", requirement: "4.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "yarn", requirement: "0.24.6", type: "runtime"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  context "with local path dependencies" do
    it "parses local path dependencies from package.json" do
      expect(described_class.analyse_contents("package.json", load_fixture("npm-local-file/package.json"))).to eq({
        platform: "npm",
        path: "package.json",
        dependencies: [
          Bibliothecary::Dependency.new(name: "left-pad", requirement: "^1.3.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "other-package", requirement: "file:src/other-package", type: "runtime", local: true),
          Bibliothecary::Dependency.new(name: "react", requirement: "^18.3.1", type: "runtime", local: false),
        ],
        kind: "manifest",
        success: true,
      })
    end

    it "parses local path dependencies from package-lock.json" do
      expect(described_class.analyse_contents("package-lock.json", load_fixture("npm-local-file/package-lock.json"))).to eq({
        platform: "npm",
        path: "package-lock.json",
        dependencies: [
          Bibliothecary::Dependency.new(name: "js-tokens", requirement: "4.0.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "left-pad", requirement: "1.3.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "lodash", requirement: "4.17.21", type: "development", local: false),
          Bibliothecary::Dependency.new(name: "loose-envify", requirement: "1.4.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "other-package", requirement: "*", type: "runtime", local: true),
          Bibliothecary::Dependency.new(name: "react", requirement: "18.3.1", type: "runtime", local: false),
        ],
        kind: "lockfile",
        success: true,
      })
    end

    it "parses local path dependencies from yarn.lock" do
      expect(described_class.analyse_contents("yarn.lock", load_fixture("npm-local-file/yarn.lock"))).to eq({
        platform: "npm",
        path: "yarn.lock",
        dependencies: [
          Bibliothecary::Dependency.new(name: "js-tokens", requirement: "4.0.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "left-pad", requirement: "1.3.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "loose-envify", requirement: "1.4.0", type: "runtime", local: false),
          Bibliothecary::Dependency.new(name: "other-package", requirement: "1.0.0", type: "runtime", local: true),
          Bibliothecary::Dependency.new(name: "react", requirement: "18.3.1", type: "runtime", local: false),
        ],
        kind: "lockfile",
        success: true,
      })
    end
  end

  it "does not parse self-referential dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn-v4-lockfile/yarn.lock"))).to eq({
      platform: "npm",
      path: "yarn.lock",
      dependencies: [
        Bibliothecary::Dependency.new(name: "js-tokens", requirement: "4.0.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "left-pad", requirement: "1.3.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "loose-envify", requirement: "1.4.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "react", requirement: "18.3.1", type: "runtime", local: false),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses package-lock.json with scm based versions" do
    contents = JSON.dump(
      {
        "name": "js-app",
        "version": "1.0.0",
        "lockfileVersion": 1,
        "requires": true,
        "dependencies": {
          "tagged": {
            "version": "git+ssh://git@github.com/some-co/tagged.git#7404d32056c7f0250aa27e038136011b",
            "from": "git+ssh://git@github.com/some-co/tagged.git#v2.10.0",
          },
          "semver": {
            "version": "git+ssh://git@github.com/some-co/semver.git#b8979ec5e34d5fac0f0b3b660dc67f2e",
            "from": "git+ssh://git@github.com/some-co/semver.git#semver:v5.5.5",
          },
          "head": {
            "version": "git+ssh://git@github.com/some-co/head.git#ecce958093a5451452ee1dd0c0d723c9",
            "from": "git+ssh://git@github.com/some-co/semver.git",
          },
        },
      }
    )

    expect(described_class.analyse_contents("package-lock.json", contents)[:dependencies]).to eq([
      Bibliothecary::Dependency.new(name: "tagged", requirement: "2.10.0", type: "runtime"),
      Bibliothecary::Dependency.new(name: "semver", requirement: "5.5.5", type: "runtime"),
      Bibliothecary::Dependency.new(name: "head", requirement: "ecce958093a5451452ee1dd0c0d723c9", type: "runtime"),
    ])
  end

  it "parses newer package-lock.json with dev and integrity fields" do
    analysis = described_class.analyse_contents("2018-package-lock/package-lock.json", load_fixture("2018-package-lock/package-lock.json"))
    expect(analysis.select { |k,_v| k != :dependencies }).to eq({
      platform: "npm",
      path: "2018-package-lock/package-lock.json",
      kind: "lockfile",
      success: true,
    })

    # spot-check dependencies to avoid having them all inline here.
    # Mostly for this "2018" lock file we want to be sure dev=true becomes
    # type=development
    dependencies = analysis[:dependencies]
    expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(
                                    name: "@vue/test-utils",
                                    requirement: "1.0.0-beta.13",
                                    type: "runtime",
                              ))
    expect(dependencies.select { |dep| dep.type == "runtime" }.length).to eq(373)
    expect(dependencies.select { |dep| dep.type == "development" }.length).to eq(1601)
    # a nested dependency
    expect(dependencies).to include(Bibliothecary::Dependency.new(name: "acorn", requirement: "4.0.13", type: "development"))
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("package.json")).to be_truthy
    expect(described_class.match?("npm-shrinkwrap.json")).to be_truthy
    expect(described_class.match?("yarn.lock")).to be_truthy
    expect(described_class.match?("website/package.json")).to be_truthy
    expect(described_class.match?("website/yarn.lock")).to be_truthy
    expect(described_class.match?("website/npm-shrinkwrap.json")).to be_truthy
    expect(described_class.match?("package-lock.json")).to be_truthy
    expect(described_class.match?("website/package-lock.json")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("foo/apackage.json")).to be_falsey
    expect(described_class.match?("anpm-shrinkwrap.json")).to be_falsey
    expect(described_class.match?("test/pass/yarn.locks")).to be_falsey
    expect(described_class.match?("sa/apackage-lock..json")).to be_falsey
  end

  it "parses dependencies that have multiple versions in package-lock.json" do
    expect(described_class.analyse_contents("package-lock.json", load_fixture("multiple_versions/package-lock.json"))).to eq({
      dependencies: [
        Bibliothecary::Dependency.new(name: "find-versions", requirement: "4.0.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "semver-regex", requirement: "3.1.3", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "semver-regex", requirement: "4.0.2", type: "runtime", local: false),
      ],
      kind: "lockfile",
      path: "package-lock.json",
      platform: "npm",
      success: true,
    })
  end

  it "parses dependencies that have multiple versions in yarn.json" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("multiple_versions/yarn.lock"))).to eq({
      dependencies: [
        Bibliothecary::Dependency.new(name: "find-versions", requirement: "4.0.0", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "semver-regex", requirement: "3.1.3", type: "runtime", local: false),
        Bibliothecary::Dependency.new(name: "semver-regex", requirement: "4.0.2", type: "runtime", local: false),
      ],
      kind: "lockfile",
      path: "yarn.lock",
      platform: "npm",
      success: true,
    })
  end

  describe ".lockfile_preference_order" do
    let!(:shrinkwrap) { Bibliothecary::FileInfo.new(".", "npm-shrinkwrap.json") }
    let!(:package_lock) { Bibliothecary::FileInfo.new(".", "package-lock.json") }
    let!(:package) { Bibliothecary::FileInfo.new(".", "package.json") }

    it "prefers npm-shrinkwrap file infos first" do
      expect(described_class.lockfile_preference_order([
        package, package_lock, shrinkwrap
      ])).to eq([ shrinkwrap, package, package_lock ])
    end

    it "changes nothing if no shrinkwrap" do
      expect(described_class.lockfile_preference_order([
        package, package_lock
      ])).to eq([ package, package_lock ])
    end
  end

  context "with different NPM lockfile versions" do
    it "parses version 1 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-1/package-lock.json", load_fixture("npm-lockfile-version-1/package-lock.json"))
      expect(analysis).to eq({
        platform: "npm",
        path: "npm-lockfile-version-1/package-lock.json",
        dependencies: [
          Bibliothecary::Dependency.new(name: "find-versions", requirement: "4.0.0", type: "runtime"), 
          Bibliothecary::Dependency.new(name: "semver-regex", requirement: "3.1.4", type: "runtime"), 
          Bibliothecary::Dependency.new(name: "semver-regex", requirement: "4.0.5", type: "runtime"),
        ],
        kind: "lockfile",
        success: true,
      })
    end

    it "parses version 2 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-2/package-lock.json", load_fixture("npm-lockfile-version-2/package-lock.json"))
      expect(analysis).to eq({
        platform: "npm",
        path: "npm-lockfile-version-2/package-lock.json",
        dependencies: [
          Bibliothecary::Dependency.new(name: "find-versions", requirement: "4.0.0", type: "runtime", local: false), 
          Bibliothecary::Dependency.new(name: "semver-regex", requirement: "3.1.4", type: "runtime", local: false), 
          Bibliothecary::Dependency.new(name: "semver-regex", requirement: "4.0.5", type: "runtime", local: false)],
        kind: "lockfile",
        success: true,
      })
    end

    it "parses version 3 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-3/package-lock.json", load_fixture("npm-lockfile-version-3/package-lock.json"))
      expect(analysis).to eq({
        platform: "npm",
        path: "npm-lockfile-version-3/package-lock.json",
        dependencies: [
          Bibliothecary::Dependency.new(name: "find-versions", requirement: "4.0.0", type: "runtime", local: false), 
          Bibliothecary::Dependency.new(name: "semver-regex", requirement: "3.1.4", type: "runtime", local: false), 
          Bibliothecary::Dependency.new(name: "semver-regex", requirement: "4.0.5", type: "runtime", local: false)],
        kind: "lockfile",
        success: true,
      })
    end
  end
end
