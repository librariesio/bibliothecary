require 'spec_helper'

describe Bibliothecary::Parsers::Carthage do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Carthage::platform_name).to eq('carthage')
  end

  it 'parses dependencies from Cartfile' do
    file = load_fixture('Cartfile')

    expect(Bibliothecary::Parsers::Carthage.analyse_file('Cartfile', file, 'Cartfile')).to eq({
      :platform=>"carthage",
      :path=>"Cartfile",
      :dependencies=>[
         {:name=>"ReactiveCocoa/ReactiveCocoa", :version=>">= 2.3.1", :type=>"runtime"},
         {:name=>"Mantle/Mantle", :version=>"~> 1.0", :type=>"runtime"},
         {:name=>"jspahrsummers/libextobjc", :version=>"== 0.4.1", :type=>"runtime"},
         {:name=>"jspahrsummers/xcconfigs", :version=>" ", :type=>"runtime"},
         {:name=>"jspahrsummers/xcconfigs", :version=>"branch ", :type=>"runtime"},
         {:name=>"https://enterprise.local/ghe/desktop/git-error-translations",:version=>" ",:type=>"runtime"},
         {:name=>"https://enterprise.local/desktop/git-error-translations2.git",:version=>"development ",:type=>"runtime"},
         {:name=>"file:///directory/to/project", :version=>"branch ", :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from Cartfile.private' do
    file = load_fixture('Cartfile.private')

    expect(Bibliothecary::Parsers::Carthage.analyse_file('Cartfile.private', file, 'Cartfile.private')).to eq({
      :platform=>"carthage",
      :path=>"Cartfile.private",
      :dependencies=>[
        {:name=>"Quick/Quick", :version=>"~> 0.9", :type=>"development"},
        {:name=>"Quick/Nimble", :version=>"~> 3.1", :type=>"development"},
        {:name=>"jspahrsummers/xcconfigs",:version=>"ec5753493605deed7358dec5f9260f503d3ed650 ",:type=>"development"}
      ]
    })
  end

  it 'parses dependencies from Cartfile.resolved' do
    file = load_fixture('Cartfile.resolved')

    expect(Bibliothecary::Parsers::Carthage.analyse_file('Cartfile.private', file, 'Cartfile.private')).to eq({
      :platform=>"carthage",
      :path=>"Cartfile.private",
      :dependencies=>[
        {:name=>"thoughtbot/Argo", :version=>"v2.2.0 ", :type=>"development"},
        {:name=>"Quick/Nimble", :version=>"v3.1.0 ", :type=>"development"},
        {:name=>"jdhealy/PrettyColors", :version=>"v3.0.0 ", :type=>"development"},
        {:name=>"Quick/Quick", :version=>"v0.9.1 ", :type=>"development"},
        {:name=>"antitypical/Result", :version=>"1.0.2 ", :type=>"development"},
        {:name=>"jspahrsummers/xcconfigs",:version=>"ec5753493605deed7358dec5f9260f503d3ed650 ",:type=>"development"},
        {:name=>"Carthage/Commandant", :version=>"0.8.3 ", :type=>"development"},
        {:name=>"ReactiveCocoa/ReactiveCocoa", :version=>"v4.0.1 ", :type=>"development"},
        {:name=>"Carthage/ReactiveTask", :version=>"0.9.1 ", :type=>"development"}
      ]
    })
  end
end
