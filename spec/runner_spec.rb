require 'spec_helper'

describe Bibliothecary::Runner do
  describe Bibliothecary::Runner::MultiManifestFilter do
    let(:subject) { described_class.new(path: path, related_files_info_entries: related_files_info_entries, runner: runner) }

    let(:path) { 'spec/fixtures' }
    let(:related_files_info_entries) do
      Bibliothecary::RelatedFilesInfo.create_from_file_infos([
        # there's no PyPI in this file so it should get filtered out
        Bibliothecary::FileInfo.new(
          'spec/fixtures',
          'spec/fixtures/cyclonedx.xml',
          nil
        ).tap { |o| o.package_manager = Bibliothecary::Parsers::Pypi },
        # this file does have Maven
        Bibliothecary::FileInfo.new(
          'spec/fixtures',
          'spec/fixtures/cyclonedx.xml',
          nil
        ).tap { |o| o.package_manager = Bibliothecary::Parsers::Maven },
        Bibliothecary::FileInfo.new(
          'spec/fixtures',
          'spec/fixtures/Gemfile.lock',
          nil
        ).tap { |o| o.package_manager = Bibliothecary::Parsers::Rubygems },
        Bibliothecary::FileInfo.new(
          'spec/fixtures',
          'spec/fixtures/package.json',
          nil
        ).tap { |o| o.package_manager = Bibliothecary::Parsers::NPM },
      ])
    end
    let!(:runner) { Bibliothecary::Runner.new(Bibliothecary::Configuration.new) }

    describe '#files_to_check' do
      it 'should produce counts' do
        expect(subject.files_to_check).to eq("cyclonedx.xml" => 2, "Gemfile.lock" => 1)
      end
    end

    describe '#no_lockfile_results' do
      it 'should pass through things without lockfiles' do
        subject.partition_file_entries!
        expect(subject.no_lockfile_results.count).to eq(1)
        expect(subject.no_lockfile_results.first.manifests).to eq(["package.json"])
      end
    end

    describe '#single_file_results' do
      it 'should produce single file results' do
        subject.partition_file_entries!
        expect(subject.single_file_results.count).to eq(1)
        expect(subject.single_file_results.first.lockfiles).to eq(["Gemfile.lock"])
      end
    end

    describe '#multiple_file_results' do
      it 'should produce multiple file results' do
        subject.partition_file_entries!

        expect(subject.multiple_file_results.count).to eq(1)
        expect(subject.multiple_file_results.first.platform).to eq("maven")
      end
    end
  end
end
