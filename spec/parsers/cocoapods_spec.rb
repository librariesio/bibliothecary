require 'spec_helper'

describe Bibliothecary::Parsers::CocoaPods do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::CocoaPods::PLATFORM_NAME).to eq('CocoaPods')
  end

  it 'parses dependencies from Podfile' do
    file = load_fixture('Podfile')

    expect(Bibliothecary::Parsers::CocoaPods.parse('Podfile', file)).to eq([
      {:name=>"Artsy-UIButtons", :requirement=>">= 0", :type=>:runtime},
      {:name=>"ORStackView", :requirement=>">= 0", :type=>:runtime},
      {:name=>"FLKAutoLayout", :requirement=>">= 0", :type=>:runtime},
      {:name=>"ISO8601DateFormatter", :requirement=>"= 0.7", :type=>:runtime},
      {:name=>"ARCollectionViewMasonryLayout", :requirement=>"~> 2.0.0", :type=>:runtime},
      {:name=>"SDWebImage", :requirement=>"~> 3.7", :type=>:runtime},
      {:name=>"SVProgressHUD", :requirement=>">= 0", :type=>:runtime},
      {:name=>"CardFlight", :requirement=>">= 0", :type=>:runtime},
      {:name=>"Stripe", :requirement=>">= 0", :type=>:runtime},
      {:name=>"ECPhoneNumberFormatter", :requirement=>">= 0", :type=>:runtime},
      {:name=>"UIImageViewAligned", :requirement=>">= 0", :type=>:runtime},
      {:name=>"DZNWebViewController", :requirement=>">= 0", :type=>:runtime},
      {:name=>"Reachability", :requirement=>">= 0", :type=>:runtime},
      {:name=>"ARTiledImageView", :requirement=>">= 0", :type=>:runtime},
      {:name=>"XNGMarkdownParser", :requirement=>">= 0", :type=>:runtime},
      {:name=>"SwiftyJSON", :requirement=>">= 0", :type=>:runtime},
      {:name=>"Swift-RAC-Macros", :requirement=>">= 0", :type=>:runtime},
      {:name=>"FBSnapshotTestCase", :requirement=>">= 0", :type=>:runtime},
      {:name=>"Nimble-Snapshots", :requirement=>">= 0", :type=>:runtime},
      {:name=>"Quick", :requirement=>">= 0", :type=>:runtime},
      {:name=>"Forgeries", :requirement=>">= 0", :type=>:runtime}
    ])
  end

  it 'parses dependencies from Podfile.lock' do
    file = load_fixture('Podfile.lock')

    expect(Bibliothecary::Parsers::CocoaPods.parse('Podfile.lock', file)).to eq([
      {:name=>"Alamofire", :requirement=>"2.0.1", :type=>"runtime"},
      {:name=>"ARAnalytics", :requirement=>"3.8.0", :type=>"runtime"},
      {:name=>"ARAnalytics", :requirement=>"3.8.0", :type=>"runtime"},
      {:name=>"ARAnalytics", :requirement=>"3.8.0", :type=>"runtime"},
      {:name=>"ARCollectionViewMasonryLayout", :requirement=>"2.0.0", :type=>"runtime"},
      {:name=>"ARTiledImageView", :requirement=>"1.2.0", :type=>"runtime"},
      {:name=>"Artsy+UIColors", :requirement=>"1.0.0", :type=>"runtime"},
      {:name=>"Artsy+UIFonts", :requirement=>"1.1.0", :type=>"runtime"},
      {:name=>"Artsy+UILabels", :requirement=>"1.3.1", :type=>"runtime"},
      {:name=>"Artsy-UIButtons", :requirement=>"1.4.0", :type=>"runtime"},
      {:name=>"CardFlight", :requirement=>"1.9.2", :type=>"runtime"},
      {:name=>"CardFlight", :requirement=>"1.9.2", :type=>"runtime"},
      {:name=>"DZNWebViewController", :requirement=>"2.0", :type=>"runtime"},
      {:name=>"ECPhoneNumberFormatter", :requirement=>"0.1.1", :type=>"runtime"},
      {:name=>"EDColor", :requirement=>"0.4.0", :type=>"runtime"},
      {:name=>"FBSnapshotTestCase", :requirement=>"1.8.1", :type=>"runtime"},
      {:name=>"FLKAutoLayout", :requirement=>"0.1.1", :type=>"runtime"},
      {:name=>"fmemopen", :requirement=>"0.0.1", :type=>"runtime"},
      {:name=>"Forgeries", :requirement=>"0.1.0", :type=>"runtime"},
      {:name=>"HockeySDK-Source", :requirement=>"3.8.1", :type=>"runtime"},
      {:name=>"ISO8601DateFormatter", :requirement=>"0.7", :type=>"runtime"},
      {:name=>"Keys", :requirement=>"1.0.0", :type=>"runtime"},
      {:name=>"Mixpanel", :requirement=>"2.8.3", :type=>"runtime"},
      {:name=>"Mixpanel", :requirement=>"2.8.3", :type=>"runtime"},
      {:name=>"Moya", :requirement=>"2.2.2", :type=>"runtime"},
      {:name=>"Moya", :requirement=>"2.2.2", :type=>"runtime"},
      {:name=>"Moya", :requirement=>"2.2.2", :type=>"runtime"},
      {:name=>"Nimble", :requirement=>"2.0.0-rc.3", :type=>"runtime"},
      {:name=>"Nimble-Snapshots", :requirement=>"1.0.0", :type=>"runtime"},
      {:name=>"NJKWebViewProgress", :requirement=>"0.2.3", :type=>"runtime"},
      {:name=>"NJKWebViewProgress", :requirement=>"0.2.3", :type=>"runtime"},
      {:name=>"NJKWebViewProgress", :requirement=>"0.2.3", :type=>"runtime"},
      {:name=>"ORStackView", :requirement=>"2.0.0", :type=>"runtime"},
      {:name=>"Quick", :requirement=>"0.6.0", :type=>"runtime"},
      {:name=>"Reachability", :requirement=>"3.1.1", :type=>"runtime"},
      {:name=>"ReactiveCocoa", :requirement=>"4.0.2-alpha-1", :type=>"runtime"},
      {:name=>"ReactiveCocoa", :requirement=>"4.0.2-alpha-1", :type=>"runtime"},
      {:name=>"ReactiveCocoa", :requirement=>"4.0.2-alpha-1", :type=>"runtime"},
      {:name=>"ReactiveCocoa", :requirement=>"4.0.2-alpha-1", :type=>"runtime"},
      {:name=>"Result", :requirement=>"0.6-beta.1", :type=>"runtime"},
      {:name=>"SDWebImage", :requirement=>"3.7.1", :type=>"runtime"},
      {:name=>"SDWebImage", :requirement=>"3.7.1", :type=>"runtime"},
      {:name=>"Stripe", :requirement=>"3.1.0", :type=>"runtime"},
      {:name=>"Stripe", :requirement=>"3.1.0", :type=>"runtime"},
      {:name=>"SVProgressHUD", :requirement=>"1.1.3", :type=>"runtime"},
      {:name=>"Swift-RAC-Macros", :requirement=>"0.3.4", :type=>"runtime"},
      {:name=>"SwiftyJSON", :requirement=>"2.2.1", :type=>"runtime"},
      {:name=>"UIImageViewAligned", :requirement=>"0.0.1", :type=>"runtime"},
      {:name=>"UIView+BooleanAnimations", :requirement=>"1.0.2", :type=>"runtime"},
      {:name=>"XNGMarkdownParser", :requirement=>"0.3.0", :type=>"runtime"}
    ])
  end

  it 'parses dependencies from example.podspec' do
    file = load_fixture('example.podspec')

    expect(Bibliothecary::Parsers::CocoaPods.parse('example.podspec', file)).to eq([
      {:name=>"CocoaLumberjack", :requirement=>">= 0", :type=>:runtime}
    ])
  end

  it 'parses dependencies from example.podspec.json' do
    file = load_fixture('example.podspec.json')

    expect(Bibliothecary::Parsers::CocoaPods.parse('example.podspec.json', file)).to eq([
      {:name=>"OpenSSL", :requirement=>["~> 1.0"], :type=>"runtime"}
    ])
  end
end
