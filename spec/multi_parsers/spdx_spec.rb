require 'spec_helper'

describe Bibliothecary::MultiParsers::SPDX do
  let!(:parser_class) do
    k = Class.new do
      def platform_name; "whatever"; end
    end

    k.send(:include, described_class)
    k
  end

  let!(:parser) { parser_class.new }

  it "handles malformed SPDX" do
    expect {}.to raise_error
    # If there is no colon on each line, it's malformed
  end

  it "handles an empty file" do
    # If array is empty, file is empty
  end

  describe "SPDX#parse!" do
  end
end
