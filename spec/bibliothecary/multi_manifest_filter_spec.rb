require 'spec_helper'

describe Bibliothecary::Runner::MultiManifestFilter do
  describe Bibliothecary::Runner::MultiManifestFilter::FileAnalysis do
    describe '#skip?' do
      it 'skips correctly' do
        expect(described_class.new(nil).skip?).to eq(true)
        expect(described_class.new({ cat: 'dog' }).skip?).to eq(true)
        expect(described_class.new({ dependencies: nil }).skip?).to eq(true)
        expect(described_class.new({ dependencies: [] }).skip?).to eq(true)
        expect(described_class.new({ dependencies: [:cat] }).skip?).to eq(false)
      end
    end
  end
end
