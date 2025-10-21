require "spec_helper"

describe Bibliothecary::Parsers::Carthage do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("carthage")
  end

  it "parses dependencies from Cartfile", :vcr do
    stub_request(:post, "https://carthage.libraries.io/cartfile?body=%23%20Require%20version%202.3.1%20or%20later%0Agithub%20%22ReactiveCocoa/ReactiveCocoa%22%20%3E=%202.3.1%0A%0A%23%20Require%20version%201.x%0Agithub%20%22Mantle/Mantle%22%20~%3E%201.0%20%20%20%20%23%20(1.0%20or%20later,%20but%20less%20than%202.0)%0A%0A%23%20Require%20exactly%20version%200.4.1%0Agithub%20%22jspahrsummers/libextobjc%22%20==%200.4.1%0A%0A%23%20Use%20the%20latest%20version%0Agithub%20%22jspahrsummers/xcconfigs%22%0A%0A%23%20Use%20the%20branch%0Agithub%20%22jspahrsummers/xcconfigs%22%20%22branch%22%0A%0A%23%20Use%20a%20project%20from%20GitHub%20Enterprise%0Agithub%20%22https://enterprise.local/ghe/desktop/git-error-translations%22%0A%0A%23%20Use%20a%20project%20from%20any%20arbitrary%20server,%20on%20the%20%22development%22%20branch%0Agit%20%22https://enterprise.local/desktop/git-error-translations2.git%22%20%22development%22%0A%0A%23%20Use%20a%20local%20project%0Agit%20%22file:///directory/to/project%22%20%22branch%22%0A").
      with(headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate([
        {name: "ReactiveCocoa/ReactiveCocoa", version: ">= 2.3.1", type: "runtime"},
        {name: "Mantle/Mantle", version: "~> 1.0", type: "runtime"},
        {name: "jspahrsummers/libextobjc", version: "== 0.4.1", type: "runtime"},
        {name: "jspahrsummers/xcconfigs", version: " ", type: "runtime"},
        {name: "jspahrsummers/xcconfigs", version: "branch ", type: "runtime"},
        {name: "https://enterprise.local/ghe/desktop/git-error-translations", version: " ", type: "runtime"},
        {name: "https://enterprise.local/desktop/git-error-translations2.git", version: "development ", type: "runtime"},
        {name: "file:///directory/to/project", version: "branch ", type: "runtime"}
      ]), headers: {})

    expect(described_class.analyse_contents("Cartfile", load_fixture("Cartfile"))).to eq({
      platform: "carthage",
      path: "Cartfile",
      dependencies: [
         Bibliothecary::Dependency.new(platform: "carthage", name: "ReactiveCocoa/ReactiveCocoa", requirement: ">= 2.3.1", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "Mantle/Mantle", requirement: "~> 1.0", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "jspahrsummers/libextobjc", requirement: "== 0.4.1", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "jspahrsummers/xcconfigs", requirement: " ", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "jspahrsummers/xcconfigs", requirement: "branch ", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "https://enterprise.local/ghe/desktop/git-error-translations", requirement: " ", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "https://enterprise.local/desktop/git-error-translations2.git", requirement: "development ", type: "runtime", source: "Cartfile"),
         Bibliothecary::Dependency.new(platform: "carthage", name: "file:///directory/to/project", requirement: "branch ", type: "runtime", source: "Cartfile"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from Cartfile.private", :vcr do
    stub_request(:post, "https://carthage.libraries.io/cartfile.private?body=github%20%22Quick/Quick%22%20~%3E%200.9%0Agithub%20%22Quick/Nimble%22%20~%3E%203.1%0Agithub%20%22jspahrsummers/xcconfigs%22%20%22ec5753493605deed7358dec5f9260f503d3ed650%22%0A").
      with(headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate([
        {name: "Quick/Quick", version: "~> 0.9", type: "development"},
        {name: "Quick/Nimble", version: "~> 3.1", type: "development"},
        {name: "jspahrsummers/xcconfigs", version: "ec5753493605deed7358dec5f9260f503d3ed650 ", type: "development"}
      ]), headers: {})

    expect(described_class.analyse_contents("Cartfile.private", load_fixture("Cartfile.private"))).to eq({
      platform: "carthage",
      path: "Cartfile.private",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "carthage", name: "Quick/Quick", requirement: "~> 0.9", type: "development", source: "Cartfile.private"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "Quick/Nimble", requirement: "~> 3.1", type: "development", source: "Cartfile.private"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "jspahrsummers/xcconfigs", requirement: "ec5753493605deed7358dec5f9260f503d3ed650 ", type: "development", source: "Cartfile.private"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from Cartfile.resolved", :vcr do
    stub_request(:post, "https://carthage.libraries.io/cartfile.resolved?body=github%20%22thoughtbot/Argo%22%20%22v2.2.0%22%0Agithub%20%22Quick/Nimble%22%20%22v3.1.0%22%0Agithub%20%22jdhealy/PrettyColors%22%20%22v3.0.0%22%0Agithub%20%22Quick/Quick%22%20%22v0.9.1%22%0Agithub%20%22antitypical/Result%22%20%221.0.2%22%0Agithub%20%22jspahrsummers/xcconfigs%22%20%22ec5753493605deed7358dec5f9260f503d3ed650%22%0Agithub%20%22Carthage/Commandant%22%20%220.8.3%22%0Agithub%20%22ReactiveCocoa/ReactiveCocoa%22%20%22v4.0.1%22%0Agithub%20%22Carthage/ReactiveTask%22%20%220.9.1%22%0A").
      with(headers: {'Expect'=>'', 'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
      to_return(status: 200, body: JSON.generate([
        {name: "thoughtbot/Argo", version: "v2.2.0 ", type: "runtime"},
        {name: "Quick/Nimble", version: "v3.1.0 ", type: "runtime"},
        {name: "jdhealy/PrettyColors", version: "v3.0.0 ", type: "runtime"},
        {name: "Quick/Quick", version: "v0.9.1 ", type: "runtime"},
        {name: "antitypical/Result", version: "1.0.2 ", type: "runtime"},
        {name: "jspahrsummers/xcconfigs", version: "ec5753493605deed7358dec5f9260f503d3ed650 ", type: "runtime"},
        {name: "Carthage/Commandant", version: "0.8.3 ", type: "runtime"},
        {name: "ReactiveCocoa/ReactiveCocoa", version: "v4.0.1 ", type: "runtime"},
        {name: "Carthage/ReactiveTask", version: "0.9.1 ", type: "runtime"}
      ]), headers: {})

    expect(described_class.analyse_contents("Cartfile.resolved", load_fixture("Cartfile.resolved"))).to eq({
      platform: "carthage",
      path: "Cartfile.resolved",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "carthage", name: "thoughtbot/Argo", requirement: "v2.2.0 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "Quick/Nimble", requirement: "v3.1.0 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "jdhealy/PrettyColors", requirement: "v3.0.0 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "Quick/Quick", requirement: "v0.9.1 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "antitypical/Result", requirement: "1.0.2 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "jspahrsummers/xcconfigs", requirement: "ec5753493605deed7358dec5f9260f503d3ed650 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "Carthage/Commandant", requirement: "0.8.3 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "ReactiveCocoa/ReactiveCocoa", requirement: "v4.0.1 ", type: "runtime", source: "Cartfile.resolved"),
        Bibliothecary::Dependency.new(platform: "carthage", name: "Carthage/ReactiveTask", requirement: "0.9.1 ", type: "runtime", source: "Cartfile.resolved"),
      ],
      kind: "lockfile",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("Cartfile")).to be_truthy
    expect(described_class.match?("Cartfile.private")).to be_truthy
    expect(described_class.match?("Cartfile.resolved")).to be_truthy
  end
end
