require "spec_helper"

describe Bibliothecary::Parsers::CocoaPods do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cocoapods")
  end

  it "parses dependencies from Podfile" do
    expect(described_class.analyse_contents("Podfile", load_fixture("Podfile"))).to eq({
      platform: "cocoapods",
      path: "Podfile",
      dependencies: [
        Bibliothecary::Dependency.new(name: "Artsy-UIButtons", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ORStackView", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "FLKAutoLayout", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ISO8601DateFormatter", requirement: "= 0.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARCollectionViewMasonryLayout", requirement: "~> 2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SDWebImage", requirement: "~> 3.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SVProgressHUD", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "CardFlight", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Stripe", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ECPhoneNumberFormatter", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "UIImageViewAligned", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "DZNWebViewController", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Reachability", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARTiledImageView", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "XNGMarkdownParser", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SwiftyJSON", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Swift-RAC-Macros", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "FBSnapshotTestCase", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Nimble-Snapshots", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Quick", requirement: ">= 0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Forgeries", requirement: ">= 0", type: "runtime"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from Podfile.lock" do
    expect(described_class.analyse_contents("Podfile.lock", load_fixture("Podfile.lock"))).to eq({
      platform: "cocoapods",
      path: "Podfile.lock",
      dependencies: [
        Bibliothecary::Dependency.new(name: "Alamofire", requirement: "2.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARAnalytics", requirement: "3.8.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARAnalytics", requirement: "3.8.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARAnalytics", requirement: "3.8.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARCollectionViewMasonryLayout", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ARTiledImageView", requirement: "1.2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Artsy+UIColors", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Artsy+UIFonts", requirement: "1.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Artsy+UILabels", requirement: "1.3.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Artsy-UIButtons", requirement: "1.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "CardFlight", requirement: "1.9.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "CardFlight", requirement: "1.9.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "DZNWebViewController", requirement: "2.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ECPhoneNumberFormatter", requirement: "0.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "EDColor", requirement: "0.4.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "FBSnapshotTestCase", requirement: "1.8.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "FLKAutoLayout", requirement: "0.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "fmemopen", requirement: "0.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Forgeries", requirement: "0.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "HockeySDK-Source", requirement: "3.8.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ISO8601DateFormatter", requirement: "0.7", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Keys", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Mixpanel", requirement: "2.8.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Mixpanel", requirement: "2.8.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Moya", requirement: "2.2.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Moya", requirement: "2.2.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Moya", requirement: "2.2.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Nimble", requirement: "2.0.0-rc.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Nimble-Snapshots", requirement: "1.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "NJKWebViewProgress", requirement: "0.2.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "NJKWebViewProgress", requirement: "0.2.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "NJKWebViewProgress", requirement: "0.2.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ORStackView", requirement: "2.0.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Quick", requirement: "0.6.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Reachability", requirement: "3.1.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Result", requirement: "0.6-beta.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SDWebImage", requirement: "3.7.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SDWebImage", requirement: "3.7.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Stripe", requirement: "3.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Stripe", requirement: "3.1.0", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SVProgressHUD", requirement: "1.1.3", type: "runtime"),
        Bibliothecary::Dependency.new(name: "Swift-RAC-Macros", requirement: "0.3.4", type: "runtime"),
        Bibliothecary::Dependency.new(name: "SwiftyJSON", requirement: "2.2.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "UIImageViewAligned", requirement: "0.0.1", type: "runtime"),
        Bibliothecary::Dependency.new(name: "UIView+BooleanAnimations", requirement: "1.0.2", type: "runtime"),
        Bibliothecary::Dependency.new(name: "XNGMarkdownParser", requirement: "0.3.0", type: "runtime"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses dependencies from example.podspec" do
    expect(described_class.analyse_contents("example.podspec", load_fixture("example.podspec"))).to eq({
      platform: "cocoapods",
      path: "example.podspec",
      dependencies: [
        Bibliothecary::Dependency.new(name: "CocoaLumberjack", requirement: ">= 0", type: "runtime"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from example.podspec.json" do
    expect(described_class.analyse_contents("example.podspec.json", load_fixture("example.podspec.json"))).to eq({
      platform: "cocoapods",
      path: "example.podspec.json",
      dependencies: [
        Bibliothecary::Dependency.new(name: "OpenSSL", requirement: ["~> 1.0"], type: "runtime"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("Podfile")).to be_truthy
    expect(described_class.match?("Podfile.lock")).to be_truthy
    expect(described_class.match?("devise.podspec")).to be_truthy
    expect(described_class.match?("foo_meh-bar.podspec")).to be_truthy
    expect(described_class.match?("devise.podspec.json")).to be_truthy
  end
end
