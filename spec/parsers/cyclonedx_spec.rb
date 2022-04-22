require 'spec_helper'

describe Bibliothecary::Parsers::CycloneDX do
  let(:unmapped_component) { "pkg:apt/krita/5.0.5" }
  # the sample cyclonedx files were created using the syft tool:
  #
  # https://github.com/anchore/syft
  #
  # install it, then run the following:
  #
  # * docker pull releases-docker.jfrog.io/jfrog/artifactory-pro:7.10.6
  # * syft releases-docker.jfrog.io/jfrog/artifactory-pro:7.10.6 --scope all-layers -o cyclonedx-xml=spec/fixtures/cyclonedx.xml -o cyclonedx-json=spec/fixtures/cyclonedx.json
  let!(:artifactory_dependencies) do
    [
      {
        platform: :npm,
        name: "1to2",
        version: "1.0.0"
      },
      {
        platform: :go,
        name: "cloud.google.com/go",
        version: "v0.38.0"
      },
      {
        platform: :maven,
        name: "org.hdrhistogram:HdrHistogram",
        version: "2.1.9"
      },
    ]
  end

  it 'has a platform name' do
    expect(described_class.platform_name).to eq('cyclonedx')
  end

  it 'handles malformed json' do
    expect { described_class.parse_json("{}") }.to raise_error(described_class::NoComponents)
  end

  it 'handles malformed xml' do
    expect { described_class.parse_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"></bom>') }.to raise_error(described_class::NoComponents)
  end

  it 'handles empty json components' do
    expect(described_class.parse_json('{ "components": [] }')).to eq({})
  end

  it 'handles empty xml components' do
    expect(described_class.parse_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components></components></bom>')).to eq({})
  end

  it 'handles unmapped json component' do
    expect(described_class.parse_json(%{{ "components": [{ "purl": "#{unmapped_component}" }] }})).to eq({})
  end

  it 'handles unmapped xml component' do
    expect(described_class.parse_xml(%{<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>})).to eq({})
  end

  it 'handles no xml pragma' do
    expect(described_class.parse_xml(%{<bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>})).to eq({})
  end

  it 'parses dependencies from cyclonedx.json' do
    result = described_class.analyse_contents('cyclonedx.json', load_fixture('cyclonedx.json'))

    artifactory_dependencies.each do |dependency|
      expect(result[:dependencies][dependency[:platform]].find { |d| d[:name] == dependency[:name] }).to eq({
        name: dependency[:name],
        requirement: dependency[:version],
        type: 'lockfile'
      })
    end
  end

  it 'parses dependencies from cyclonedx.xml' do
    result = described_class.analyse_contents('cyclonedx.xml', load_fixture('cyclonedx.xml'))

    artifactory_dependencies.each do |dependency|
      expect(result[:dependencies][dependency[:platform]].find { |d| d[:name] == dependency[:name] }).to eq({
        name: dependency[:name],
        requirement: dependency[:version],
        type: 'lockfile'
      })
    end
  end

  describe 'ManifestEntries.full_name_for_purl' do
    it 'should handle formats correctly' do
      maven = PackageURL.parse("pkg:maven/cat/dog@1.2.3")

      expect(described_class::ManifestEntries.full_name_for_purl(maven)).to eq("cat:dog")

      npm = PackageURL.parse("pkg:npm/cat/dog@1.2.3")

      expect(described_class::ManifestEntries.full_name_for_purl(npm)).to eq("cat/dog")
    end
  end
end
