# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::CocoaPods do
  it "has a platform name" do
    expect(described_class.parser_name).to eq("cocoapods")
  end

  it "parses dependencies from Podfile" do
    expect(described_class.analyse_contents("Podfile", load_fixture("Podfile"))).to eq({
                                                                                         parser: "cocoapods",
                                                                                         path: "Podfile",
                                                                                         project_name: nil,
                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Artsy-UIButtons", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ORStackView", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "FLKAutoLayout", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ISO8601DateFormatter", requirement: "= 0.7", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARCollectionViewMasonryLayout", requirement: "~> 2.0.0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SDWebImage", requirement: "~> 3.7", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SVProgressHUD", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "CardFlight", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Stripe", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ECPhoneNumberFormatter", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "UIImageViewAligned", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "DZNWebViewController", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Reachability", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARTiledImageView", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "XNGMarkdownParser", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SwiftyJSON", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Swift-RAC-Macros", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "FBSnapshotTestCase", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Nimble-Snapshots", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Quick", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Forgeries", requirement: ">= 0", type: "runtime", source: "Podfile"),
      ],
                                                                                         kind: "manifest",
                                                                                         success: true,
                                                                                       })
  end

  it "parses dependencies from Podfile.lock" do
    expect(described_class.analyse_contents("Podfile.lock", load_fixture("Podfile.lock"))).to eq({
                                                                                                   parser: "cocoapods",
                                                                                                   path: "Podfile.lock",
                                                                                                   project_name: nil,
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Alamofire", requirement: "2.0.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARAnalytics", requirement: "3.8.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARAnalytics", requirement: "3.8.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARAnalytics", requirement: "3.8.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARCollectionViewMasonryLayout", requirement: "2.0.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARTiledImageView", requirement: "1.2.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Artsy+UIColors", requirement: "1.0.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Artsy+UIFonts", requirement: "1.1.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Artsy+UILabels", requirement: "1.3.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Artsy-UIButtons", requirement: "1.4.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "CardFlight", requirement: "1.9.2", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "CardFlight", requirement: "1.9.2", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "DZNWebViewController", requirement: "2.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ECPhoneNumberFormatter", requirement: "0.1.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "EDColor", requirement: "0.4.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "FBSnapshotTestCase", requirement: "1.8.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "FLKAutoLayout", requirement: "0.1.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "fmemopen", requirement: "0.0.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Forgeries", requirement: "0.1.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "HockeySDK-Source", requirement: "3.8.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ISO8601DateFormatter", requirement: "0.7", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Keys", requirement: "1.0.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Mixpanel", requirement: "2.8.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Mixpanel", requirement: "2.8.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Moya", requirement: "2.2.2", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Moya", requirement: "2.2.2", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Moya", requirement: "2.2.2", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Nimble", requirement: "2.0.0-rc.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Nimble-Snapshots", requirement: "1.0.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "NJKWebViewProgress", requirement: "0.2.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "NJKWebViewProgress", requirement: "0.2.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "NJKWebViewProgress", requirement: "0.2.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ORStackView", requirement: "2.0.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Quick", requirement: "0.6.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Reachability", requirement: "3.1.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ReactiveCocoa", requirement: "4.0.2-alpha-1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Result", requirement: "0.6-beta.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SDWebImage", requirement: "3.7.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SDWebImage", requirement: "3.7.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Stripe", requirement: "3.1.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Stripe", requirement: "3.1.0", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SVProgressHUD", requirement: "1.1.3", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Swift-RAC-Macros", requirement: "0.3.4", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SwiftyJSON", requirement: "2.2.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "UIImageViewAligned", requirement: "0.0.1", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "UIView+BooleanAnimations", requirement: "1.0.2", type: "runtime", source: "Podfile.lock"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "XNGMarkdownParser", requirement: "0.3.0", type: "runtime", source: "Podfile.lock"),
      ],
                                                                                                   kind: "lockfile",
                                                                                                   success: true,
                                                                                                 })
  end

  it "parses dependencies from example.podspec" do
    expect(described_class.analyse_contents("example.podspec", load_fixture("example.podspec"))).to eq({
                                                                                                         parser: "cocoapods",
                                                                                                         path: "example.podspec",
                                                                                                         project_name: nil,
                                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "CocoaLumberjack", requirement: ">= 0", type: "runtime", source: "example.podspec"),
      ],
                                                                                                         kind: "manifest",
                                                                                                         success: true,
                                                                                                       })
  end

  it "parses dependencies from example.podspec.json" do
    expect(described_class.analyse_contents("example.podspec.json", load_fixture("example.podspec.json"))).to eq({
                                                                                                                   parser: "cocoapods",
                                                                                                                   path: "example.podspec.json",
                                                                                                                   project_name: nil,
                                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "OpenSSL", requirement: ["~> 1.0"], type: "runtime", source: "example.podspec.json"),
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
