require 'spec_helper'

def file_info(filename, parser)
  Bibliothecary::FileInfo.new(
    'spec/fixtures',
    "spec/fixtures/#{filename}",
    nil
  ).tap { |o| o.package_manager = parser }
end

def maven_file_info(filename)
  file_info(filename, Bibliothecary::Parsers::Maven)
end

describe Bibliothecary::Runner do
  describe Bibliothecary::Runner::MultiManifestFilter do
    let(:subject) { described_class.new(path: path, related_files_info_entries: related_files_info_entries, runner: runner) }

    let(:path) { 'spec/fixtures' }
    let(:related_files_info_entries) do
      Bibliothecary::RelatedFilesInfo.create_from_file_infos(
        [
          # there's no PyPI in this file so it should get filtered out
          file_info("cyclonedx.xml", Bibliothecary::Parsers::Pypi),
          # this file does have Maven
          maven_file_info("cyclonedx.xml"),
          file_info("Gemfile.lock", Bibliothecary::Parsers::Rubygems),
          file_info("package.json", Bibliothecary::Parsers::NPM)
        ]
      )
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

    context "maven multi-lockfile rfi" do
      let(:related_files_info_entries) do
        Bibliothecary::RelatedFilesInfo.create_from_file_infos(
          [
            maven_file_info('pom.xml'),
            maven_file_info('maven-dependency-tree.txt'),
            maven_file_info('maven-resolved-dependencies.txt')
          ]
        )
      end

      it 'should not duplicate the rfi' do
        expect(subject.results.count).to eq(1)
        expect(subject.results).to eq(related_files_info_entries)
      end
    end

    context "multiple maven multi-lockfile rfis" do
      let(:related_files_info_entries) do
        file_infos1 = [
          maven_file_info('pom.xml'),
          maven_file_info('maven-dependency-tree.txt'),
          maven_file_info('maven-resolved-dependencies.txt')
        ]

        file_infos2 = file_infos1.dup
        [file_infos1, file_infos2].flat_map { |fi| Bibliothecary::RelatedFilesInfo.create_from_file_infos(fi) }
      end

      it 'should not deduplicate distinct rfis' do
        expect(subject.results.count).to eq(2)
        expect(subject.results).to eq(related_files_info_entries)
      end
    end
  end
end
