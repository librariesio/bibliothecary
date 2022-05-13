require "spec_helper"

describe Bibliothecary::FileInfo, :focus do
  describe "#ungroupable?" do
    let(:file_info) { described_class.new(folder_path, full_path, contents) }
    let(:folder_path) { "spec/fixtures" }
    let(:contents) { nil }

    subject { file_info.groupable? }

    context "ungroupable" do
      let(:full_path) { "spec/fixtures/dependencies.csv" }

      it "determines if file is groupable" do
        file_info.package_manager = Bibliothecary::Parsers::NPM
        expect(subject).to eq(false)
      end
    end

    context "groupable" do
      let(:full_path) { "spec/fixtures/package.json" }

      it "determines if file is groupable" do
        file_info.package_manager = Bibliothecary::Parsers::NPM
        expect(subject).to eq(true)
      end
    end
  end
end
