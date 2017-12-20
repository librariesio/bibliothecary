require 'spec_helper'

describe Bibliothecary::Parsers::NPM do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('npm')
  end

  it 'parses dependencies from package.json' do
    expect(described_class.analyse_contents('package.json', load_fixture('package.json'))).to eq({
      :platform=>"npm",
      :path=>"package.json",
      :dependencies=>[
        {:name=>"babel", :requirement=>"^4.6.6", :type=>"runtime"},
        {:name=>"mocha", :requirement=>"^2.2.1", :type=>"development"}
      ],
      kind: 'manifest'
    })
  end

  it 'parses dependencies from npm-shrinkwrap.json' do
    expect(described_class.analyse_contents('npm-shrinkwrap.json', load_fixture('npm-shrinkwrap.json'))).to eq({
      :platform=>"npm",
      :path=>"npm-shrinkwrap.json",
      :dependencies=>[
        {:name=>"babel", :requirement=>"4.7.16", :type=>"runtime"},
        {:name=>"body-parser", :requirement=>"1.13.3", :type=>"runtime"},
        {:name=>"bugsnag", :requirement=>"1.6.5", :type=>"runtime"},
        {:name=>"cookie-session", :requirement=>"1.2.0", :type=>"runtime"},
        {:name=>"debug", :requirement=>"2.2.0", :type=>"runtime"},
        {:name=>"deep-diff", :requirement=>"0.3.2", :type=>"runtime"},
        {:name=>"deep-equal", :requirement=>"1.0.0", :type=>"runtime"},
        {:name=>"express", :requirement=>"4.13.3", :type=>"runtime"},
        {:name=>"express-session", :requirement=>"1.11.3", :type=>"runtime"},
        {:name=>"jade", :requirement=>"1.11.0", :type=>"runtime"},
        {:name=>"js-yaml", :requirement=>"3.4.0", :type=>"runtime"},
        {:name=>"memwatch-next", :requirement=>"0.2.9", :type=>"runtime"},
        {:name=>"multer", :requirement=>"0.1.8", :type=>"runtime"},
        {:name=>"qs", :requirement=>"2.4.2", :type=>"runtime"},
        {:name=>"redis", :requirement=>"0.12.1", :type=>"runtime"},
        {:name=>"semver", :requirement=>"4.3.6", :type=>"runtime"},
        {:name=>"serve-static", :requirement=>"1.10.0", :type=>"runtime"},
        {:name=>"toml", :requirement=>"2.3.0", :type=>"runtime"}
      ],
      kind: 'lockfile'
    })
  end

  it 'parses dependencies from yarn.lock' do
    expect(described_class.analyse_contents('yarn.lock', load_fixture('yarn.lock'))).to eq({
      :platform=>"npm",
      :path=>"yarn.lock",
      :dependencies=>[
        {name: "body-parser", version: "1.16.1", type: "runtime"},
        {name: "bytes", version: "2.4.0", type: "runtime"},
        {name: "content-type", version: "1.0.2", type: "runtime"},
        {name: "debug", version: "2.6.1", type: "runtime"},
        {name: "depd", version: "1.1.0", type: "runtime"},
        {name: "ee-first", version: "1.1.1", type: "runtime"},
        {name: "http-errors", version: "1.5.1", type: "runtime"},
        {name: "iconv-lite", version: "0.4.15", type: "runtime"},
        {name: "inherits", version: "2.0.3", type: "runtime"},
        {name: "media-typer", version: "0.3.0", type: "runtime"},
        {name: "mime-db", version: "1.26.0", type: "runtime"},
        {name: "mime-types", version: "2.1.14", type: "runtime"},
        {name: "ms", version: "0.7.2", type: "runtime"},
        {name: "on-finished", version: "2.3.0", type: "runtime"},
        {name: "qs", version: "6.2.1", type: "runtime"},
        {name: "raw-body", version: "2.2.0", type: "runtime"},
        {name: "setprototypeof", version: "1.0.2", type: "runtime"},
        {name: "statuses", version: "1.3.1", type: "runtime"},
        {name: "type-is", version: "1.6.14", type: "runtime"},
        {name: "unpipe", version: "1.0.0", type: "runtime"}
      ],
      kind: 'lockfile'
    })
  end

  it 'parses dependencies from package-lock.json' do
    expect(described_class.analyse_contents('package-lock.json', load_fixture('package-lock.json'))).to eq({
      :platform=>"npm",
      :path=>"package-lock.json",
      :dependencies=>[{:name=>"accepts", :requirement=>"1.3.3", :type=>"runtime"}, {:name=>"ajv", :requirement=>"4.11.8", :type=>"runtime"}, {:name=>"ansi-escapes", :requirement=>"1.4.0", :type=>"runtime"}, {:name=>"ansi-regex", :requirement=>"2.1.1", :type=>"runtime"}, {:name=>"ansi-styles", :requirement=>"2.2.1", :type=>"runtime"}, {:name=>"array-find-index", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"array-flatten", :requirement=>"1.1.1", :type=>"runtime"}, {:name=>"asn1", :requirement=>"0.2.3", :type=>"runtime"}, {:name=>"assert-plus", :requirement=>"0.2.0", :type=>"runtime"}, {:name=>"asynckit", :requirement=>"0.4.0", :type=>"runtime"}, {:name=>"aws-sign2", :requirement=>"0.6.0", :type=>"runtime"}, {:name=>"aws4", :requirement=>"1.6.0", :type=>"runtime"}, {:name=>"babel-runtime", :requirement=>"6.23.0", :type=>"runtime"}, {:name=>"balanced-match", :requirement=>"0.4.2", :type=>"runtime"}, {:name=>"bcrypt-pbkdf", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"bl", :requirement=>"1.2.1", :type=>"runtime"}, {:name=>"body-parser", :requirement=>"1.17.2", :type=>"runtime"}, {:name=>"boom", :requirement=>"2.10.1", :type=>"runtime"}, {:name=>"brace-expansion", :requirement=>"1.1.7", :type=>"runtime"}, {:name=>"browserify-zlib", :requirement=>"0.1.4", :type=>"runtime"}, {:name=>"buffer-shims", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"builtin-modules", :requirement=>"1.1.1", :type=>"runtime"}, {:name=>"bytes", :requirement=>"2.4.0", :type=>"runtime"}, {:name=>"camelcase", :requirement=>"4.1.0", :type=>"runtime"}, {:name=>"caseless", :requirement=>"0.12.0", :type=>"runtime"}, {:name=>"chalk", :requirement=>"1.1.3", :type=>"runtime"}, {:name=>"chownr", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"ci-info", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"cli-cursor", :requirement=>"2.1.0", :type=>"runtime"}, {:name=>"cli-width", :requirement=>"2.1.0", :type=>"runtime"}, {:name=>"cmd-shim", :requirement=>"2.0.2", :type=>"runtime"}, {:name=>"co", :requirement=>"4.6.0", :type=>"runtime"}, {:name=>"combined-stream", :requirement=>"1.0.5", :type=>"runtime"}, {:name=>"commander", :requirement=>"2.9.0", :type=>"runtime"}, {:name=>"concat-map", :requirement=>"0.0.1", :type=>"runtime"}, {:name=>"content-disposition", :requirement=>"0.5.2", :type=>"runtime"}, {:name=>"content-type", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"cookie", :requirement=>"0.3.1", :type=>"runtime"}, {:name=>"cookie-signature", :requirement=>"1.0.6", :type=>"runtime"}, {:name=>"core-js", :requirement=>"2.4.1", :type=>"runtime"}, {:name=>"core-util-is", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"cryptiles", :requirement=>"2.0.5", :type=>"runtime"}, {:name=>"currently-unhandled", :requirement=>"0.4.1", :type=>"runtime"}, {:name=>"dashdash", :requirement=>"1.14.1", :type=>"runtime"}, {:name=>"death", :requirement=>"1.1.0", :type=>"runtime"}, {:name=>"debug", :requirement=>"2.6.7", :type=>"runtime"}, {:name=>"delayed-stream", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"depd", :requirement=>"1.1.0", :type=>"runtime"}, {:name=>"destroy", :requirement=>"1.0.4", :type=>"runtime"}, {:name=>"detect-indent", :requirement=>"5.0.0", :type=>"runtime"}, {:name=>"duplexify", :requirement=>"3.5.0", :type=>"runtime"}, {:name=>"ecc-jsbn", :requirement=>"0.1.1", :type=>"runtime"}, {:name=>"ee-first", :requirement=>"1.1.1", :type=>"runtime"}, {:name=>"encodeurl", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"end-of-stream", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"escape-html", :requirement=>"1.0.3", :type=>"runtime"}, {:name=>"escape-string-regexp", :requirement=>"1.0.5", :type=>"runtime"}, {:name=>"etag", :requirement=>"1.8.0", :type=>"runtime"}, {:name=>"express", :requirement=>"4.15.3", :type=>"runtime"}, {:name=>"extend", :requirement=>"3.0.1", :type=>"runtime"}, {:name=>"external-editor", :requirement=>"2.0.4", :type=>"runtime"}, {:name=>"extsprintf", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"figures", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"finalhandler", :requirement=>"1.0.3", :type=>"runtime"}, {:name=>"forever-agent", :requirement=>"0.6.1", :type=>"runtime"}, {:name=>"form-data", :requirement=>"2.1.4", :type=>"runtime"}, {:name=>"forwarded", :requirement=>"0.1.0", :type=>"runtime"}, {:name=>"fresh", :requirement=>"0.5.0", :type=>"runtime"}, {:name=>"fs.realpath", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"getpass", :requirement=>"0.1.7", :type=>"runtime"}, {:name=>"glob", :requirement=>"7.1.2", :type=>"runtime"}, {:name=>"graceful-fs", :requirement=>"4.1.11", :type=>"runtime"}, {:name=>"graceful-readlink", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"gunzip-maybe", :requirement=>"1.4.0", :type=>"runtime"}, {:name=>"har-schema", :requirement=>"1.0.5", :type=>"runtime"}, {:name=>"har-validator", :requirement=>"4.2.1", :type=>"runtime"}, {:name=>"has-ansi", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"hawk", :requirement=>"3.1.3", :type=>"runtime"}, {:name=>"hoek", :requirement=>"2.16.3", :type=>"runtime"}, {:name=>"http-errors", :requirement=>"1.6.1", :type=>"runtime"}, {:name=>"http-signature", :requirement=>"1.1.1", :type=>"runtime"}, {:name=>"iconv-lite", :requirement=>"0.4.15", :type=>"runtime"}, {:name=>"inflight", :requirement=>"1.0.6", :type=>"runtime"}, {:name=>"inherits", :requirement=>"2.0.3", :type=>"runtime"}, {:name=>"ini", :requirement=>"1.3.4", :type=>"runtime"}, {:name=>"inquirer", :requirement=>"3.0.6", :type=>"runtime"}, {:name=>"invariant", :requirement=>"2.2.2", :type=>"runtime"}, {:name=>"ipaddr.js", :requirement=>"1.3.0", :type=>"runtime"}, {:name=>"is-builtin-module", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"is-ci", :requirement=>"1.0.10", :type=>"runtime"}, {:name=>"is-deflate", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"is-fullwidth-code-point", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"is-gzip", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"is-promise", :requirement=>"2.1.0", :type=>"runtime"}, {:name=>"is-typedarray", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"isarray", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"isstream", :requirement=>"0.1.2", :type=>"runtime"}, {:name=>"jodid25519", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"js-tokens", :requirement=>"3.0.1", :type=>"runtime"}, {:name=>"jsbn", :requirement=>"0.1.1", :type=>"runtime"}, {:name=>"jschardet", :requirement=>"1.4.2", :type=>"runtime"}, {:name=>"json-schema", :requirement=>"0.2.3", :type=>"runtime"}, {:name=>"json-stable-stringify", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"json-stringify-safe", :requirement=>"5.0.1", :type=>"runtime"}, {:name=>"jsonify", :requirement=>"0.0.0", :type=>"runtime"}, {:name=>"jsprim", :requirement=>"1.4.0", :type=>"runtime"}, {:name=>"leven", :requirement=>"2.1.0", :type=>"runtime"}, {:name=>"lodash", :requirement=>"4.17.4", :type=>"runtime"}, {:name=>"loose-envify", :requirement=>"1.3.1", :type=>"runtime"}, {:name=>"loud-rejection", :requirement=>"1.6.0", :type=>"runtime"}, {:name=>"media-typer", :requirement=>"0.3.0", :type=>"runtime"}, {:name=>"merge-descriptors", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"methods", :requirement=>"1.1.2", :type=>"runtime"}, {:name=>"mime", :requirement=>"1.3.4", :type=>"runtime"}, {:name=>"mime-db", :requirement=>"1.27.0", :type=>"runtime"}, {:name=>"mime-types", :requirement=>"2.1.15", :type=>"runtime"}, {:name=>"mimic-fn", :requirement=>"1.1.0", :type=>"runtime"}, {:name=>"minimatch", :requirement=>"3.0.4", :type=>"runtime"}, {:name=>"minimist", :requirement=>"0.0.8", :type=>"runtime"}, {:name=>"mkdirp", :requirement=>"0.5.1", :type=>"runtime"}, {:name=>"ms", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"mute-stream", :requirement=>"0.0.7", :type=>"runtime"}, {:name=>"negotiator", :requirement=>"0.6.1", :type=>"runtime"}, {:name=>"node-emoji", :requirement=>"1.5.1", :type=>"runtime"}, {:name=>"oauth-sign", :requirement=>"0.8.2", :type=>"runtime"}, {:name=>"object-path", :requirement=>"0.11.4", :type=>"runtime"}, {:name=>"on-finished", :requirement=>"2.3.0", :type=>"runtime"}, {:name=>"once", :requirement=>"1.3.3", :type=>"runtime"}, {:name=>"onetime", :requirement=>"2.0.1", :type=>"runtime"}, {:name=>"os-tmpdir", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"pako", :requirement=>"0.2.9", :type=>"runtime"}, {:name=>"parseurl", :requirement=>"1.3.1", :type=>"runtime"}, {:name=>"path-is-absolute", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"path-to-regexp", :requirement=>"0.1.7", :type=>"runtime"}, {:name=>"peek-stream", :requirement=>"1.1.2", :type=>"runtime"}, {:name=>"performance-now", :requirement=>"0.2.0", :type=>"runtime"}, {:name=>"process-nextick-args", :requirement=>"1.0.7", :type=>"runtime"}, {:name=>"proper-lockfile", :requirement=>"2.0.1", :type=>"runtime"}, {:name=>"proxy-addr", :requirement=>"1.1.4", :type=>"runtime"}, {:name=>"pump", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"pumpify", :requirement=>"1.3.5", :type=>"runtime"}, {:name=>"punycode", :requirement=>"1.4.1", :type=>"runtime"}, {:name=>"qs", :requirement=>"6.4.0", :type=>"runtime"}, {:name=>"range-parser", :requirement=>"1.2.0", :type=>"runtime"}, {:name=>"raw-body", :requirement=>"2.2.0", :type=>"runtime"}, {:name=>"read", :requirement=>"1.0.7", :type=>"runtime"}, {:name=>"readable-stream", :requirement=>"2.2.9", :type=>"runtime"}, {:name=>"regenerator-runtime", :requirement=>"0.10.5", :type=>"runtime"}, {:name=>"request", :requirement=>"2.81.0", :type=>"runtime"}, {:name=>"request-capture-har", :requirement=>"1.2.2", :type=>"runtime"}, {:name=>"restore-cursor", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"retry", :requirement=>"0.10.1", :type=>"runtime"}, {:name=>"rimraf", :requirement=>"2.6.1", :type=>"runtime"}, {:name=>"run-async", :requirement=>"2.3.0", :type=>"runtime"}, {:name=>"rx", :requirement=>"4.1.0", :type=>"runtime"}, {:name=>"safe-buffer", :requirement=>"5.0.1", :type=>"runtime"}, {:name=>"semver", :requirement=>"5.3.0", :type=>"runtime"}, {:name=>"send", :requirement=>"0.15.3", :type=>"runtime"}, {:name=>"serve-static", :requirement=>"1.12.3", :type=>"runtime"}, {:name=>"setprototypeof", :requirement=>"1.0.3", :type=>"runtime"}, {:name=>"signal-exit", :requirement=>"3.0.2", :type=>"runtime"}, {:name=>"sntp", :requirement=>"1.0.9", :type=>"runtime"}, {:name=>"spdx-correct", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"spdx-expression-parse", :requirement=>"1.0.4", :type=>"runtime"}, {:name=>"spdx-license-ids", :requirement=>"1.2.2", :type=>"runtime"}, {:name=>"sshpk", :requirement=>"1.13.0", :type=>"runtime"}, {:name=>"statuses", :requirement=>"1.3.1", :type=>"runtime"}, {:name=>"stream-shift", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"string_decoder", :requirement=>"1.0.1", :type=>"runtime"}, {:name=>"string-width", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"string.prototype.codepointat", :requirement=>"0.2.0", :type=>"runtime"}, {:name=>"stringstream", :requirement=>"0.0.5", :type=>"runtime"}, {:name=>"strip-ansi", :requirement=>"3.0.1", :type=>"runtime"}, {:name=>"strip-bom", :requirement=>"3.0.0", :type=>"runtime"}, {:name=>"supports-color", :requirement=>"2.0.0", :type=>"runtime"}, {:name=>"tar-fs", :requirement=>"1.15.2", :type=>"runtime"}, {:name=>"tar-stream", :requirement=>"1.5.4", :type=>"runtime"}, {:name=>"through", :requirement=>"2.3.8", :type=>"runtime"}, {:name=>"through2", :requirement=>"2.0.3", :type=>"runtime"}, {:name=>"tmp", :requirement=>"0.0.31", :type=>"runtime"}, {:name=>"tough-cookie", :requirement=>"2.3.2", :type=>"runtime"}, {:name=>"tunnel-agent", :requirement=>"0.6.0", :type=>"runtime"}, {:name=>"tweetnacl", :requirement=>"0.14.5", :type=>"runtime"}, {:name=>"type-is", :requirement=>"1.6.15", :type=>"runtime"}, {:name=>"unpipe", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"util-deprecate", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"utils-merge", :requirement=>"1.0.0", :type=>"runtime"}, {:name=>"uuid", :requirement=>"3.0.1", :type=>"runtime"}, {:name=>"v8-compile-cache", :requirement=>"1.1.0", :type=>"runtime"}, {:name=>"validate-npm-package-license", :requirement=>"3.0.1", :type=>"runtime"}, {:name=>"vary", :requirement=>"1.1.1", :type=>"runtime"}, {:name=>"verror", :requirement=>"1.3.6", :type=>"runtime"}, {:name=>"wrappy", :requirement=>"1.0.2", :type=>"runtime"}, {:name=>"xtend", :requirement=>"4.0.1", :type=>"runtime"}, {:name=>"yarn", :requirement=>"0.24.6", :type=>"runtime"}],
      kind: 'lockfile'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('package.json')).to be_truthy
    expect(described_class.match?('npm-shrinkwrap.json')).to be_truthy
    expect(described_class.match?('yarn.lock')).to be_truthy
    expect(described_class.match?('website/package.json')).to be_truthy
    expect(described_class.match?('website/yarn.lock')).to be_truthy
    expect(described_class.match?('website/npm-shrinkwrap.json')).to be_truthy
    expect(described_class.match?('package-lock.json')).to be_truthy
    expect(described_class.match?('website/package-lock.json')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('node_modules/foo/package.json')).to be_falsey
    expect(described_class.match?('node_modules/foo/npm-shrinkwrap.json')).to be_falsey
    expect(described_class.match?('node_modules/foo/yarn.lock')).to be_falsey
    expect(described_class.match?('node_modules/foo/package-lock.json')).to be_falsey
  end
end
