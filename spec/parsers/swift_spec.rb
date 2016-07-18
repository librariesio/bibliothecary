require 'spec_helper'

describe Bibliothecary::Parsers::Swift do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Swift::platform_name).to eq('swift')
  end

  it 'parses dependencies from Package.swift' do
    expect(Bibliothecary::Parsers::Swift.analyse_file('Package.swift', fixture_path('Package.swift'))).to eq({
      :platform=>"swift",
      :path=>"spec/fixtures/Package.swift",
      :dependencies=>[
        {:name=>"github.com/qutheory/vapor", :version=>"0.12.0 - 0.12.9223372036854775807", :type=>"runtime"},
        {:name=>"github.com/czechboy0/Tasks", :version=>"0.2.0 - 0.2.9223372036854775807", :type=>"runtime"},
        {:name=>"github.com/czechboy0/Environment", :version=>"0.4.0 - 0.4.9223372036854775807", :type=>"runtime"}
      ]
    })
  end
end
