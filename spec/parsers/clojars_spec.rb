require "spec_helper"

describe Bibliothecary::Parsers::Clojars do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("clojars")
  end

  it "parses dependencies from project.clj", :vcr do
    stub_request(:post, "https://clojars.libraries.io/project.clj").
      with(
        body: "(defproject clojars-json \"0.1.0\"\n  :description \"FIXME: write description\"\n  :url \"http://example.com/FIXME\"\n  :license {:name \"Eclipse Public License\"\n            :url \"http://www.eclipse.org/legal/epl-v10.html\"}\n  :dependencies [[org.clojure/clojure \"1.6.0\"]\n                 [cheshire \"5.4.0\"]\n                 [compojure \"1.3.2\"]\n                 [ring/ring-defaults \"0.1.2\"]\n                 [ring/ring-jetty-adapter \"1.2.1\"]]\n  :plugins [[lein-ring \"0.8.13\"]]\n  :min-lein-version \"2.0.0\"\n  :ring {:handler clojars-json.core/app}\n  :uberjar-name \"clojars-json.jar\"\n  :profiles {:uberjar {:aot :all}}\n  :main clojars-json.core\n  )\n",
        headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate([
        "dependencies",
        [
          ["org.clojure/clojure", "1.6.0"],
          ["cheshire", "5.4.0"],
          ["compojure", "1.3.2"],
          ["ring/ring-defaults", "0.1.2"],
          ["ring/ring-jetty-adapter", "1.2.1"]
        ]
      ]), headers: {})

    expect(described_class.analyse_contents("project.clj", load_fixture("project.clj"))).to eq({
      platform: "clojars",
      path: "project.clj",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "clojars", name: "org.clojure/clojure", requirement: "1.6.0", type: "runtime", source: "project.clj"),
        Bibliothecary::Dependency.new(platform: "clojars", name: "cheshire", requirement: "5.4.0", type: "runtime", source: "project.clj"),
        Bibliothecary::Dependency.new(platform: "clojars", name: "compojure", requirement: "1.3.2", type: "runtime", source: "project.clj"),
        Bibliothecary::Dependency.new(platform: "clojars", name: "ring/ring-defaults", requirement: "0.1.2", type: "runtime", source: "project.clj"),
        Bibliothecary::Dependency.new(platform: "clojars", name: "ring/ring-jetty-adapter", requirement: "1.2.1", type: "runtime", source: "project.clj"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("project.clj")).to be_truthy
  end
end
