# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::NPM do
  it "has a platform name" do
    expect(described_class.parser_name).to eq("npm")
  end

  it "doesn't group dependencies.csv with npm files" do
    npm_results, other_results = Bibliothecary.find_manifests_from_paths([
        "spec/fixtures/package.json",
        "spec/fixtures/package-lock.json",
        "spec/fixtures/dependencies.csv",
    ]).partition { |r| r.parser == "npm" }

    expect(npm_results.length).to eq(1)

    expect(
      npm_results.find do |r|
        r.manifests == ["spec/fixtures/package.json"] &&
        r.lockfiles == ["spec/fixtures/package-lock.json"]
      end
    ).not_to eq(nil)

    expect(other_results.length).to eq(1)

    expect(
      other_results.find do |r|
        r.manifests == [] &&
        r.lockfiles == ["spec/fixtures/dependencies.csv"]
      end
    ).not_to eq(nil)
  end

  it "parses dependencies from npm-ls.json" do
    expect(described_class.analyse_contents("npm-ls.json", load_fixture("npm-ls.json"))).to eq({
                                                                                                 parser: "npm",
                                                                                                 path: "npm-ls.json",
                                                                                                 project_name: nil,
                                                                                                 dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "ansicolor", requirement: "1.1.93", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "babel-cli", requirement: "6.26.0", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.9", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "babel-polyfill", requirement: "6.26.0", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "core-js", requirement: "2.6.12", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.21", type: "runtime", source: "npm-ls.json"),
      ],
                                                                                                 kind: "lockfile",
                                                                                                 success: true,
                                                                                               })
  end

  it "parses dependencies from package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("package.json"))).to eq({
                                                                                                   parser: "npm",
                                                                                                   path: "package.json",
                                                                                                   project_name: "librarian",
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "^4.6.6", type: "runtime", local: false, source: "package.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "@some-scope/actual-package", requirement: "^1.1.3", original_name: "alias-package-name", original_requirement: "^1.1.3", type: "runtime", local: false, source: "package.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "^2.2.1", type: "development", local: false, source: "package.json"),
      ],
                                                                                                   kind: "manifest",
                                                                                                   success: true,
                                                                                                 })
  end

  it "parses dependencies from npm-shrinkwrap.json" do
    expect(described_class.analyse_contents("npm-shrinkwrap.json", load_fixture("npm-shrinkwrap.json"))).to include({
                                                                                                                      parser: "npm",
                                                                                                                      path: "npm-shrinkwrap.json",
                                                                                                                      kind: "lockfile",
                                                                                                                      project_name: nil,
                                                                                                                      success: true,
                                                                                                                    })
    expect(described_class.analyse_contents("npm-shrinkwrap.json", load_fixture("npm-shrinkwrap.json"))[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "4.7.16", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "body-parser", requirement: "1.13.3", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "bugsnag", requirement: "1.6.5", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "cookie-session", requirement: "1.2.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.2.0", type: "development", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "deep-diff", requirement: "0.3.2", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "deep-equal", requirement: "1.0.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "express", requirement: "4.13.3", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "express-session", requirement: "1.11.3", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jade", requirement: "1.11.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "js-yaml", requirement: "3.4.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "memwatch-next", requirement: "0.2.9", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "multer", requirement: "0.1.8", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "qs", requirement: "2.4.2", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "redis", requirement: "0.12.1", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "semver", requirement: "4.3.6", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "serve-static", requirement: "1.10.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "toml", requirement: "2.3.0", type: "runtime", source: "npm-shrinkwrap.json")
    )
  end

  context "with a yarn.lock" do
    let(:expected_deps) do
      [
        Bibliothecary::Dependency.new(platform: "npm", name: "body-parser", requirement: "1.16.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "bytes", requirement: "2.4.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "content-type", requirement: "1.0.2", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "depd", requirement: "1.1.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ee-first", requirement: "1.1.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "http-errors", requirement: "1.5.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.15", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "inherits", requirement: "2.0.3", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "media-typer", requirement: "0.3.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime-db", requirement: "1.26.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime-types", requirement: "2.1.14", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "0.7.2", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "on-finished", requirement: "2.3.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "qs", requirement: "6.2.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "raw-body", requirement: "2.2.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "setprototypeof", requirement: "1.0.2", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "statuses", requirement: "1.3.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "@some-scope/actual-package", requirement: "1.1.3", original_name: "alias-package-name", original_requirement: "1.1.3", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "type-is", requirement: "1.6.14", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "unpipe", requirement: "1.0.0", type: nil, local: false, source: "yarn.lock"),
      ]
    end

    it "parses dependencies" do
      result = described_class.analyse_contents("yarn.lock", load_fixture("yarn.lock"))
      expect(result).to eq({
                             parser: "npm",
                             path: "yarn.lock",
                             dependencies: expected_deps,
                             kind: "lockfile",
                             project_name: nil,
                             success: true,
                           })
    end

    it "parses dependencies with windows line endings" do
      result = described_class.analyse_contents(
        "yarn.lock",
        load_fixture("yarn.lock").gsub("\n", "\r\n")
      )
      expect(result).to eq({
                             parser: "npm",
                             path: "yarn.lock",
                             dependencies: expected_deps,
                             kind: "lockfile",
                             project_name: nil,
                             success: true,
                           })
    end
  end

  it "parses git dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn-with-git-repo/yarn.lock"))).to eq({
                                                                                                                parser: "npm",
                                                                                                                path: "yarn.lock",
                                                                                                                project_name: nil,
                                                                                                                dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "vue", requirement: "2.6.12", type: nil, local: false, source: "yarn.lock"),
        ],
                                                                                                                kind: "lockfile",
                                                                                                                success: true,
                                                                                                              })
  end

  it "parses dependencies from pnpm-lock.yaml with lockfile version 5" do
    expected_deps = [
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/helper-string-parser", requirement: "7.27.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/helper-validator-identifier", requirement: "7.27.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/types", requirement: "7.28.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "acorn-babel", requirement: "0.11.1-38", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "acorn", requirement: "5.7.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "amdefine", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ansi-regex", requirement: "2.1.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ansi-styles", requirement: "2.2.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.7.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.8.15", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.9.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "async-each", requirement: "0.1.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "4.7.16", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "balanced-match", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "brace-expansion", requirement: "1.1.11", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "chalk", requirement: "1.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "chokidar", requirement: "0.12.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "0.6.1", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.20.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.3.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commoner", requirement: "0.10.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "concat-map", requirement: "0.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "convert-source-map", requirement: "0.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "core-js", requirement: "0.6.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "core-util-is", requirement: "1.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.2.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.9", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "defined", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "detect-indent", requirement: "3.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "detective", requirement: "4.7.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "diff", requirement: "1.4.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.2", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.5", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima-fb", requirement: "15001.1001.0-dev-harmony-fb", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima", requirement: "2.7.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima", requirement: "3.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "estraverse", requirement: "1.9.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esutils", requirement: "1.1.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "fs-readdir-recursive", requirement: "0.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "fsevents", requirement: "0.3.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "get-stdin", requirement: "4.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "3.2.11", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "5.0.15", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "globals", requirement: "6.4.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "2.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "4.2.11", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "growl", requirement: "1.9.2", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "has-ansi", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.24", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "inflight", requirement: "1.0.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "inherits", requirement: "2.0.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "is-finite", requirement: "1.1.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "is-integer", requirement: "1.0.7", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "isarray", requirement: "0.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jade", requirement: "0.26.3", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jsesc", requirement: "0.5.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "0.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "leven", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "line-numbers", requirement: "0.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "3.10.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "lru-cache", requirement: "2.7.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "0.2.14", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "0.3.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "3.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "0.0.8", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "1.2.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.3.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.1", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "2.5.3", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "0.7.1", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "nan", requirement: "2.22.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "object-assign", requirement: "4.1.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "once", requirement: "1.4.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "output-file-sync", requirement: "1.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "path-is-absolute", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "private", requirement: "0.1.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "q", requirement: "1.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "readable-stream", requirement: "1.0.34", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "readdirp", requirement: "1.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "recast", requirement: "0.10.43", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "recast", requirement: "0.11.23", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regenerate", requirement: "1.4.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regenerator-babel", requirement: "0.8.13-2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regexpu", requirement: "1.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regjsgen", requirement: "0.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regjsparser", requirement: "0.1.5", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "repeating", requirement: "1.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "safer-buffer", requirement: "2.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "shebang-regex", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "sigmund", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "slash", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map-support", requirement: "0.2.10", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.1.32", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.4.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.5.7", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "string_decoder", requirement: "0.10.31", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "strip-ansi", requirement: "3.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "1.2.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "through", requirement: "2.3.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "to-fast-properties", requirement: "1.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "to-iso-string", requirement: "0.0.2", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "trim-right", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "wrappy", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "4.0.5", original_name: "alias-package", original_requirement: "4.0.5", type: "runtime", source: "pnpm-lock.yaml"),
]
    result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-5/pnpm-lock.yaml"))

    expect(result).to eq({
                           parser: "npm",
                           path: "pnpm-lock.yaml",
                           dependencies: expected_deps,
                           kind: "lockfile",
                           project_name: nil,
                           success: true,
                         })
  end

  it "parses dependencies from pnpm-lock.yaml with lockfile version 6" do
    expected_deps = [
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/helper-string-parser", requirement: "7.27.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/helper-validator-identifier", requirement: "7.27.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/types", requirement: "7.28.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "acorn-babel", requirement: "0.11.1-38", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "acorn", requirement: "5.7.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "amdefine", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ansi-regex", requirement: "2.1.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ansi-styles", requirement: "2.2.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.7.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.8.15", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.9.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "async-each", requirement: "0.1.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "4.7.16", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "balanced-match", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "brace-expansion", requirement: "1.1.12", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "chalk", requirement: "1.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "chokidar", requirement: "0.12.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "0.6.1", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.20.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.3.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commoner", requirement: "0.10.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "concat-map", requirement: "0.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "convert-source-map", requirement: "0.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "core-js", requirement: "0.6.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "core-util-is", requirement: "1.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.2.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.9", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "defined", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "detect-indent", requirement: "3.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "detective", requirement: "4.7.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "diff", requirement: "1.4.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.2", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.5", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima-fb", requirement: "15001.1001.0-dev-harmony-fb", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima", requirement: "2.7.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima", requirement: "3.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "estraverse", requirement: "1.9.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esutils", requirement: "1.1.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "fs-readdir-recursive", requirement: "0.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "fsevents", requirement: "0.3.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "get-stdin", requirement: "4.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "3.2.11", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "5.0.15", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "globals", requirement: "6.4.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "2.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "4.2.11", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "growl", requirement: "1.9.2", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "has-ansi", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.24", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "inflight", requirement: "1.0.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "inherits", requirement: "2.0.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "is-finite", requirement: "1.1.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "is-integer", requirement: "1.0.7", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "isarray", requirement: "0.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jade", requirement: "0.26.3", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jsesc", requirement: "0.5.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "0.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "leven", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "line-numbers", requirement: "0.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "3.10.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "lru-cache", requirement: "2.7.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "0.2.14", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "0.3.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "3.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "0.0.8", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "1.2.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.3.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.1", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "2.5.3", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "0.7.1", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "nan", requirement: "2.23.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "object-assign", requirement: "4.1.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "once", requirement: "1.4.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "output-file-sync", requirement: "1.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "path-is-absolute", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "private", requirement: "0.1.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "q", requirement: "1.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "readable-stream", requirement: "1.0.34", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "readdirp", requirement: "1.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "recast", requirement: "0.10.43", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "recast", requirement: "0.11.23", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regenerate", requirement: "1.4.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regenerator-babel", requirement: "0.8.13-2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regexpu", requirement: "1.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regjsgen", requirement: "0.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regjsparser", requirement: "0.1.5", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "repeating", requirement: "1.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "safer-buffer", requirement: "2.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "shebang-regex", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "sigmund", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "slash", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map-support", requirement: "0.2.10", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.1.32", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.4.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.5.7", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "string_decoder", requirement: "0.10.31", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "strip-ansi", requirement: "3.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "1.2.0", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "through", requirement: "2.3.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "to-fast-properties", requirement: "1.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "to-iso-string", requirement: "0.0.2", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "trim-right", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "wrappy", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "4.0.5", original_name: "alias-package", original_requirement: "4.0.5", type: "runtime", source: "pnpm-lock.yaml"),
]
    result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-6/pnpm-lock.yaml"))

    expect(result).to eq({
                           parser: "npm",
                           path: "pnpm-lock.yaml",
                           dependencies: expected_deps,
                           kind: "lockfile",
                           project_name: nil,
                           success: true,
                         })
  end

  it "parses dependencies from pnpm-lock.yaml with lockfile version 9" do
    expected_deps = [
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/helper-string-parser", requirement: "7.27.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/helper-validator-identifier", requirement: "7.27.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/types", requirement: "7.28.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "acorn-babel", requirement: "0.11.1-38", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "acorn", requirement: "5.7.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "amdefine", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ansi-regex", requirement: "2.1.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ansi-styles", requirement: "2.2.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.7.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.8.15", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ast-types", requirement: "0.9.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "async-each", requirement: "0.1.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "4.7.16", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "balanced-match", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "brace-expansion", requirement: "1.1.11", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "chalk", requirement: "1.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "chokidar", requirement: "0.12.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "0.6.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.20.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "commoner", requirement: "0.10.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "concat-map", requirement: "0.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "convert-source-map", requirement: "0.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "core-js", requirement: "0.6.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "core-util-is", requirement: "1.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.9", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "defined", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "detect-indent", requirement: "3.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "detective", requirement: "4.7.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "diff", requirement: "1.4.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.5", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima-fb", requirement: "15001.1001.0-dev-harmony-fb", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima", requirement: "2.7.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esprima", requirement: "3.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "estraverse", requirement: "1.9.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "esutils", requirement: "1.1.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "fs-readdir-recursive", requirement: "0.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "fsevents", requirement: "0.3.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "get-stdin", requirement: "4.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "3.2.11", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "5.0.15", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "globals", requirement: "6.4.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "2.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "4.2.11", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "growl", requirement: "1.9.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "has-ansi", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.24", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "inflight", requirement: "1.0.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "inherits", requirement: "2.0.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "is-finite", requirement: "1.1.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "is-integer", requirement: "1.0.7", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "isarray", requirement: "0.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jade", requirement: "0.26.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jsesc", requirement: "0.5.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "0.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "leven", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "line-numbers", requirement: "0.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "3.10.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "lru-cache", requirement: "2.7.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "0.2.14", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "0.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "3.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "0.0.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "1.2.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.6", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "2.5.3", type: "development", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "0.7.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "nan", requirement: "2.22.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "object-assign", requirement: "4.1.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "once", requirement: "1.4.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "output-file-sync", requirement: "1.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "path-is-absolute", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "private", requirement: "0.1.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "q", requirement: "1.5.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "readable-stream", requirement: "1.0.34", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "readdirp", requirement: "1.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "recast", requirement: "0.10.43", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "recast", requirement: "0.11.23", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regenerate", requirement: "1.4.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regenerator-babel", requirement: "0.8.13-2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regexpu", requirement: "1.3.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regjsgen", requirement: "0.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "regjsparser", requirement: "0.1.5", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "repeating", requirement: "1.1.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "safer-buffer", requirement: "2.1.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "shebang-regex", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "sigmund", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "slash", requirement: "1.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map-support", requirement: "0.2.10", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.1.32", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.4.4", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "source-map", requirement: "0.5.7", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "string_decoder", requirement: "0.10.31", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "strip-ansi", requirement: "3.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "1.2.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "2.0.0", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "through", requirement: "2.3.8", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "to-fast-properties", requirement: "1.0.3", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "to-iso-string", requirement: "0.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "trim-right", requirement: "1.0.1", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "wrappy", requirement: "1.0.2", type: "runtime", source: "pnpm-lock.yaml"),
      Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "3.24.2", original_name: "alias-package", original_requirement: "3.24.2", type: "runtime", source: "pnpm-lock.yaml"),
]
    result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-9/pnpm-lock.yaml"))

    expect(result).to eq({
                           parser: "npm",
                           path: "pnpm-lock.yaml",
                           dependencies: expected_deps,
                           kind: "lockfile",
                           project_name: nil,
                           success: true,
                         })
  end

  it "parses git dependencies from package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("yarn-with-git-repo/package.json"))).to eq({
                                                                                                                      parser: "npm",
                                                                                                                      path: "package.json",
                                                                                                                      project_name: "fake-yarn",
                                                                                                                      dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "vue", requirement: "https://github.com/vuejs/vue.git#v2.6.12", type: "runtime", local: false, source: "package.json"),
      ],
                                                                                                                      kind: "manifest",
                                                                                                                      success: true,
                                                                                                                    })
  end

  it "wont load package-lock.json from a package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("package-lock.json"))).to match({
                                                                                                           parser: "npm",
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
                                                                                                             parser: "npm",
                                                                                                             path: "package-lock.json",
                                                                                                             project_name: nil,
                                                                                                             dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "accepts", requirement: "1.3.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ajv", requirement: "4.11.8", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ansi-escapes", requirement: "1.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ansi-regex", requirement: "2.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ansi-styles", requirement: "2.2.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "array-find-index", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "array-flatten", requirement: "1.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "asn1", requirement: "0.2.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "assert-plus", requirement: "0.2.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "asynckit", requirement: "0.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "aws-sign2", requirement: "0.6.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "aws4", requirement: "1.6.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "babel-runtime", requirement: "6.23.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "balanced-match", requirement: "0.4.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "bcrypt-pbkdf", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "bl", requirement: "1.2.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "body-parser", requirement: "1.17.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "boom", requirement: "2.10.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "brace-expansion", requirement: "1.1.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "browserify-zlib", requirement: "0.1.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "buffer-shims", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "builtin-modules", requirement: "1.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "bytes", requirement: "2.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "camelcase", requirement: "4.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "caseless", requirement: "0.12.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "chalk", requirement: "1.1.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "chownr", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ci-info", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "cli-cursor", requirement: "2.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "cli-width", requirement: "2.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "cmd-shim", requirement: "2.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "co", requirement: "4.6.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "combined-stream", requirement: "1.0.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "commander", requirement: "2.9.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "concat-map", requirement: "0.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "content-disposition", requirement: "0.5.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "content-type", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "cookie", requirement: "0.3.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "cookie-signature", requirement: "1.0.6", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "core-js", requirement: "2.4.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "core-util-is", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "cryptiles", requirement: "2.0.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "currently-unhandled", requirement: "0.4.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "dashdash", requirement: "1.14.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "assert-plus", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "death", requirement: "1.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "delayed-stream", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "depd", requirement: "1.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "destroy", requirement: "1.0.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "detect-indent", requirement: "5.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "duplexify", requirement: "3.5.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ecc-jsbn", requirement: "0.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ee-first", requirement: "1.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "encodeurl", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "end-of-stream", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "escape-html", requirement: "1.0.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "escape-string-regexp", requirement: "1.0.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "etag", requirement: "1.8.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "express", requirement: "4.15.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "extend", requirement: "3.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "external-editor", requirement: "2.0.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.17", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "extsprintf", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "figures", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "finalhandler", requirement: "1.0.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "forever-agent", requirement: "0.6.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "form-data", requirement: "2.1.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "forwarded", requirement: "0.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "fresh", requirement: "0.5.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "fs.realpath", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "getpass", requirement: "0.1.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "assert-plus", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "glob", requirement: "7.1.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "graceful-fs", requirement: "4.1.11", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "graceful-readlink", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "gunzip-maybe", requirement: "1.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "har-schema", requirement: "1.0.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "har-validator", requirement: "4.2.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "has-ansi", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "hawk", requirement: "3.1.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "hoek", requirement: "2.16.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "http-errors", requirement: "1.6.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "http-signature", requirement: "1.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.15", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "inflight", requirement: "1.0.6", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "inherits", requirement: "2.0.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ini", requirement: "1.3.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "inquirer", requirement: "3.0.6", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "invariant", requirement: "2.2.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ipaddr.js", requirement: "1.3.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-builtin-module", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-ci", requirement: "1.0.10", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-deflate", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-fullwidth-code-point", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-gzip", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-promise", requirement: "2.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "is-typedarray", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "isarray", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "isstream", requirement: "0.1.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "jodid25519", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "3.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "jsbn", requirement: "0.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "jschardet", requirement: "1.4.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "json-schema", requirement: "0.2.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "json-stable-stringify", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "json-stringify-safe", requirement: "5.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "jsonify", requirement: "0.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "jsprim", requirement: "1.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "assert-plus", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "leven", requirement: "2.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.3.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "loud-rejection", requirement: "1.6.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "media-typer", requirement: "0.3.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "merge-descriptors", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "methods", requirement: "1.1.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime", requirement: "1.3.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime-db", requirement: "1.27.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime-types", requirement: "2.1.15", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mimic-fn", requirement: "1.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "minimatch", requirement: "3.0.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "minimist", requirement: "0.0.8", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mkdirp", requirement: "0.5.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mute-stream", requirement: "0.0.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "negotiator", requirement: "0.6.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "node-emoji", requirement: "1.5.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "oauth-sign", requirement: "0.8.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "object-path", requirement: "0.11.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "on-finished", requirement: "2.3.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "once", requirement: "1.3.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "onetime", requirement: "2.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "os-tmpdir", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "pako", requirement: "0.2.9", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "parseurl", requirement: "1.3.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "path-is-absolute", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "path-to-regexp", requirement: "0.1.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "peek-stream", requirement: "1.1.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "performance-now", requirement: "0.2.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "process-nextick-args", requirement: "1.0.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "proper-lockfile", requirement: "2.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "proxy-addr", requirement: "1.1.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "pump", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "end-of-stream", requirement: "1.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "once", requirement: "1.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "pumpify", requirement: "1.3.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "punycode", requirement: "1.4.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "qs", requirement: "6.4.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "range-parser", requirement: "1.2.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "raw-body", requirement: "2.2.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "read", requirement: "1.0.7", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "readable-stream", requirement: "2.2.9", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "regenerator-runtime", requirement: "0.10.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "request", requirement: "2.81.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "request-capture-har", requirement: "1.2.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "restore-cursor", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "retry", requirement: "0.10.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "rimraf", requirement: "2.6.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "run-async", requirement: "2.3.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "rx", requirement: "4.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "safe-buffer", requirement: "5.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "semver", requirement: "5.3.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "send", requirement: "0.15.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "serve-static", requirement: "1.12.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "setprototypeof", requirement: "1.0.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "signal-exit", requirement: "3.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "sntp", requirement: "1.0.9", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "spdx-correct", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "spdx-expression-parse", requirement: "1.0.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "spdx-license-ids", requirement: "1.2.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "sshpk", requirement: "1.13.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "assert-plus", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "statuses", requirement: "1.3.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "stream-shift", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "string_decoder", requirement: "1.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "string-width", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "string.prototype.codepointat", requirement: "0.2.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "stringstream", requirement: "0.0.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "strip-ansi", requirement: "3.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "strip-bom", requirement: "3.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "supports-color", requirement: "2.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "tar-fs", requirement: "1.15.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "tar-stream", requirement: "1.5.4", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "through", requirement: "2.3.8", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "through2", requirement: "2.0.3", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "tmp", requirement: "0.0.31", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "tough-cookie", requirement: "2.3.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "tunnel-agent", requirement: "0.6.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "tweetnacl", requirement: "0.14.5", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "type-is", requirement: "1.6.15", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "unpipe", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "util-deprecate", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "utils-merge", requirement: "1.0.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "uuid", requirement: "3.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "v8-compile-cache", requirement: "1.1.0", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "validate-npm-package-license", requirement: "3.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "vary", requirement: "1.1.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "verror", requirement: "1.3.6", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "wrappy", requirement: "1.0.2", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "xtend", requirement: "4.0.1", type: "runtime", source: "package-lock.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "yarn", requirement: "0.24.6", type: "runtime", source: "package-lock.json"),
      ],
                                                                                                             kind: "lockfile",
                                                                                                             success: true,
                                                                                                           })
  end

  context "with local path dependencies" do
    it "parses local path dependencies from package.json" do
      expect(described_class.analyse_contents("package.json", load_fixture("npm-local-file/package.json"))).to eq({
                                                                                                                    parser: "npm",
                                                                                                                    path: "package.json",
                                                                                                                    project_name: "npm-bad",
                                                                                                                    dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "^1.3.0", type: "runtime", local: false, source: "package.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "other-package", requirement: "file:src/other-package", type: "runtime", local: true, source: "package.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "^18.3.1", type: "runtime", local: false, source: "package.json"),
        ],
                                                                                                                    kind: "manifest",
                                                                                                                    success: true,
                                                                                                                  })
    end

    it "parses local path dependencies from package-lock.json" do
      expect(described_class.analyse_contents("package-lock.json", load_fixture("npm-local-file/package-lock.json"))).to eq({
                                                                                                                              parser: "npm",
                                                                                                                              path: "package-lock.json",
                                                                                                                              dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "4.0.0", type: "runtime", local: false, source: "package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "1.3.0", type: "runtime", local: false, source: "package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.21", type: "development", local: false, source: "package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.4.0", type: "runtime", local: false, source: "package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "other-package", requirement: "*", type: "runtime", local: true, source: "package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "18.3.1", type: "runtime", local: false, source: "package-lock.json"),
        ],
                                                                                                                              kind: "lockfile",
                                                                                                                              project_name: nil,
                                                                                                                              success: true,
                                                                                                                            })
    end

    it "parses local path dependencies from yarn.lock" do
      expect(described_class.analyse_contents("yarn.lock", load_fixture("npm-local-file/yarn.lock"))).to eq({
                                                                                                              parser: "npm",
                                                                                                              path: "yarn.lock",
                                                                                                              project_name: nil,
                                                                                                              dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "4.0.0", type: nil, local: false, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "1.3.0", type: nil, local: false, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.4.0", type: nil, local: false, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "other-package", requirement: "1.0.0", type: nil, local: true, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "18.3.1", type: nil, local: false, source: "yarn.lock"),
        ],
                                                                                                              kind: "lockfile",
                                                                                                              success: true,
                                                                                                            })
    end
  end

  it "does not parse self-referential dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn-v4-lockfile/yarn.lock"))).to eq({
                                                                                                              parser: "npm",
                                                                                                              path: "yarn.lock",
                                                                                                              project_name: nil,
                                                                                                              dependencies: [
  Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "4.0.0", type: nil, local: false, source: "yarn.lock"),
  Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "1.3.0", type: nil, local: false, source: "yarn.lock"),
  Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.4.0", type: nil, local: false, source: "yarn.lock"),
  Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "18.3.1", type: nil, local: false, source: "yarn.lock"),
  Bibliothecary::Dependency.new(platform: "npm", name: "strip-ansi", requirement: "6.0.1", original_name: "strip-ansi-cjs", original_requirement: "6.0.1", type: nil, local: false, source: "yarn.lock"),
      ],
                                                                                                              kind: "lockfile",
                                                                                                              success: true,
                                                                                                            })
  end

  it "parses package-lock.json with scm based versions" do
    contents = JSON.dump(
      {
        name: "js-app",
        version: "1.0.0",
        lockfileVersion: 1,
        requires: true,
        dependencies: {
          tagged: {
            version: "git+ssh://git@github.com/some-co/tagged.git#7404d32056c7f0250aa27e038136011b",
            from: "git+ssh://git@github.com/some-co/tagged.git#v2.10.0",
          },
          semver: {
            version: "git+ssh://git@github.com/some-co/semver.git#b8979ec5e34d5fac0f0b3b660dc67f2e",
            from: "git+ssh://git@github.com/some-co/semver.git#semver:v5.5.5",
          },
          head: {
            version: "git+ssh://git@github.com/some-co/head.git#ecce958093a5451452ee1dd0c0d723c9",
            from: "git+ssh://git@github.com/some-co/semver.git",
          },
        },
      }
    )

    expect(described_class.analyse_contents("package-lock.json", contents)[:dependencies]).to eq([
      Bibliothecary::Dependency.new(platform: "npm", name: "tagged", requirement: "2.10.0", type: "runtime", source: "package-lock.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "semver", requirement: "5.5.5", type: "runtime", source: "package-lock.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "head", requirement: "ecce958093a5451452ee1dd0c0d723c9", type: "runtime", source: "package-lock.json"),
    ])
  end

  it "parses newer package-lock.json with dev and integrity fields" do
    analysis = described_class.analyse_contents("2018-package-lock/package-lock.json", load_fixture("2018-package-lock/package-lock.json"))
    expect(analysis.except(:dependencies)).to eq({
                                                   parser: "npm",
                                                   path: "2018-package-lock/package-lock.json",
                                                   project_name: nil,
                                                   kind: "lockfile",
                                                   success: true,
                                                 })

    # spot-check dependencies to avoid having them all inline here.
    # Mostly for this "2018" lock file we want to be sure dev=true becomes
    # type=development
    dependencies = analysis[:dependencies]
    expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "npm",
                                                                name: "@vue/test-utils",
                                                                requirement: "1.0.0-beta.13",
                                                                type: "runtime",
                                                                source: "2018-package-lock/package-lock.json"))
    expect(dependencies.select { |dep| dep.type == "runtime" }.length).to eq(373)
    expect(dependencies.select { |dep| dep.type == "development" }.length).to eq(1601)
    # a nested dependency
    expect(dependencies).to include(Bibliothecary::Dependency.new(platform: "npm", name: "acorn", requirement: "4.0.13", type: "development", source: "2018-package-lock/package-lock.json"))
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
                                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", local: false, source: "package-lock.json"),
                                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.3", type: "runtime", local: false, source: "package-lock.json"),
                                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.2", type: "runtime", local: false, source: "package-lock.json"),
                                                                                                                               ],
                                                                                                                               kind: "lockfile",
                                                                                                                               project_name: nil,
                                                                                                                               path: "package-lock.json",
                                                                                                                               parser: "npm",
                                                                                                                               success: true,
                                                                                                                             })
  end

  it "parses dependencies that have multiple versions in yarn.json" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("multiple_versions/yarn.lock"))).to eq({
                                                                                                               dependencies: [
                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: nil, local: false, source: "yarn.lock"),
                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.3", type: nil, local: false, source: "yarn.lock"),
                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.2", type: nil, local: false, source: "yarn.lock"),
                                                                                                               ],
                                                                                                               kind: "lockfile",
                                                                                                               path: "yarn.lock",
                                                                                                               project_name: nil,
                                                                                                               parser: "npm",
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
      ])).to eq([shrinkwrap, package, package_lock])
    end

    it "changes nothing if no shrinkwrap" do
      expect(described_class.lockfile_preference_order([
        package, package_lock
      ])).to eq([package, package_lock])
    end
  end

  context "with different NPM lockfile versions" do
    it "parses version 1 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-1/package-lock.json", load_fixture("npm-lockfile-version-1/package-lock.json"))
      expect(analysis).to eq({
                               parser: "npm",
                               path: "npm-lockfile-version-1/package-lock.json",
                               project_name: nil,
                               dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", source: "npm-lockfile-version-1/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.4", type: "runtime", source: "npm-lockfile-version-1/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.5", type: "runtime", source: "npm-lockfile-version-1/package-lock.json"),
        ],
                               kind: "lockfile",
                               success: true,
                             })
    end

    it "parses version 2 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-2/package-lock.json", load_fixture("npm-lockfile-version-2/package-lock.json"))
      expect(analysis).to eq({
                               parser: "npm",
                               path: "npm-lockfile-version-2/package-lock.json",
                               dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", local: false, source: "npm-lockfile-version-2/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.4", type: "runtime", local: false, source: "npm-lockfile-version-2/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.5", type: "runtime", local: false, source: "npm-lockfile-version-2/package-lock.json"),
],
                               kind: "lockfile",
                               project_name: nil,
                               success: true,
                             })
    end

    it "parses version 3 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-3/package-lock.json", load_fixture("npm-lockfile-version-3/package-lock.json"))
      expect(analysis).to eq({
                               parser: "npm",
                               path: "npm-lockfile-version-3/package-lock.json",
                               project_name: nil,
                               dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "@some-scope/actual-package", requirement: "1.1.3", original_name: "alias-package-name", original_requirement: "1.1.3", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.4", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.5", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json"),
],
                               kind: "lockfile",
                               success: true,
                             })
    end
  end

  it "parses bun.lock dependency file" do
    expect(described_class.analyse_contents("bun.lock", load_fixture("bun.lock"))).to eq({
                                                                                           parser: "npm",
                                                                                           path: "bun.lock",
                                                                                           project_name: nil,
                                                                                           dependencies: [

       Bibliothecary::Dependency.new(platform: "npm", name: "@types/bun", requirement: "1.2.5", type: "development", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "@types/node", requirement: "22.13.10", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "@types/ws", requirement: "8.5.14", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "3.24.2", original_name: "alias-package", original_requirement: "3.24.2", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "6.23.0", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "bun-types", requirement: "1.2.5", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "isarray", requirement: "file:../isarray", type: "runtime", local: true, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.21", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "prettier", requirement: "3.5.3", type: "development", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "typescript", requirement: "5.8.2", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "undici-types", requirement: "6.20.0", type: "runtime", local: false, source: "bun.lock"),
     ],
                                                                                           kind: "lockfile",
                                                                                           success: true,
                                                                                         })
  end

  it "parses bun.lock workspace dependency file" do
    expect(described_class.analyse_contents("bun.lock", load_fixture("bun-workspace/bun.lock"))).to eq({
                                                                                                         parser: "npm",
                                                                                                         path: "bun.lock",
                                                                                                         project_name: nil,
                                                                                                         dependencies: [

       Bibliothecary::Dependency.new(platform: "npm", name: "@types/node", requirement: "25.2.1", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "@workspace/package-a", requirement: "workspace:packages/package-a", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "@workspace/package-b", requirement: "workspace:packages/package-b", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "bun-types", requirement: "1.3.8", type: "development", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "chalk", requirement: "5.6.2", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "sprintf-js", requirement: "1.1.3", type: "runtime", local: false, source: "bun.lock"),
       Bibliothecary::Dependency.new(platform: "npm", name: "undici-types", requirement: "7.16.0", type: "runtime", local: false, source: "bun.lock"),
     ],
                                                                                                         kind: "lockfile",
                                                                                                         success: true,
                                                                                                       })
  end
end
