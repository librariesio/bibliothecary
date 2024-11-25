require "spec_helper"

describe Bibliothecary::Configuration do
  let(:config) { described_class.new }

  it "should have a default list of ignored dirs" do
    expect(config.ignored_dirs).to eq([".git", "node_modules", "bower_components", "vendor", "dist"])
  end
end
