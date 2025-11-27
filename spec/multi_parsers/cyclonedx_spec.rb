# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::MultiParsers::CycloneDX do
  let(:unmapped_component) { "pkg:apt/debian/krita@5.0.5" }

  it "handles malformed json" do
    expect { described_class.parse_cyclonedx_json("{}") }.to raise_error(described_class::NoComponents)
  end

  it "handles malformed xml" do
    expect { described_class.parse_cyclonedx_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"></bom>') }.to raise_error(described_class::NoComponents)
  end

  it "handles empty json components" do
    expect(described_class.parse_cyclonedx_json('{ "components": [] }')).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles empty xml components" do
    expect(described_class.parse_cyclonedx_xml('<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components></components></bom>')).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles unmapped json component" do
    expect(described_class.parse_cyclonedx_json(%({ "components": [{ "purl": "#{unmapped_component}" }] }))).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles unmapped xml component" do
    expect(described_class.parse_cyclonedx_xml(%(<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  it "handles no xml pragma" do
    expect(described_class.parse_cyclonedx_xml(%(<bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq(Bibliothecary::ParserResult.new(dependencies: []))
  end

  context "with full_sbom option" do
    it "includes unmapped json components" do
      purl_string = "pkg:apt/debian/krita@5.0.5"
      result = described_class.parse_cyclonedx_json(%({ "components": [{ "purl": "#{purl_string}" }] }), options: { full_sbom: true, filename: "test-full-sbom.json" })
      expect(result.dependencies.length).to eq(1)
      expect(result.dependencies.first.platform).to eq("apt")
      expect(result.dependencies.first.name).to eq("debian/krita")
      expect(result.dependencies.first.requirement).to eq("5.0.5")
    end

    it "includes unmapped xml components" do
      purl_string = "pkg:apt/debian/krita@5.0.5"
      result = described_class.parse_cyclonedx_xml(%(<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{purl_string}</purl></component></components></bom>), options: { full_sbom: true, filename: "test-full-sbom.xml" })
      expect(result.dependencies.length).to eq(1)
      expect(result.dependencies.first.platform).to eq("apt")
      expect(result.dependencies.first.name).to eq("debian/krita")
      expect(result.dependencies.first.requirement).to eq("5.0.5")
    end

    it "still includes mapped components" do
      result = described_class.parse_cyclonedx_json('{ "components": [{ "purl": "pkg:npm/express@4.17.1" }] }', options: { full_sbom: true, filename: "test-mapped-full-sbom.json" })
      expect(result.dependencies.length).to eq(1)
      expect(result.dependencies.first.platform).to eq("npm")
      expect(result.dependencies.first.name).to eq("express")
      expect(result.dependencies.first.requirement).to eq("4.17.1")
    end
  end

  describe "ManifestEntries#parse!" do
    it "should not mutate the manifest sent in" do
      queue = [1, 2, 3]

      entries = described_class::ManifestEntries.new(parse_queue: queue)

      entries.parse! do |_item, _parse_queue|
        nil
      end

      expect(queue.count).to eq(3)
    end
  end

  it "has a platform name" do
    expect(described_class.parser_name).to eq("cyclonedx")
  end

  let(:unmapped_component) { "pkg:apt/krita/5.0.5" }

  it "handles empty json components" do
    expect(described_class.analyse_contents("cyclonedx.json", '{ "components": [] }')).to eq({
                                                                                               parser: "cyclonedx",
                                                                                               path: "cyclonedx.json",
                                                                                               project_name: nil,
                                                                                               dependencies: [],
                                                                                               kind: "lockfile",
                                                                                               success: true,
                                                                                             })
  end

  it "handles empty xml components" do
    expect(described_class.analyse_contents("cyclonedx.xml", '<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components></components></bom>')).to eq({
                                                                                                                                                                                                parser: "cyclonedx",
                                                                                                                                                                                                path: "cyclonedx.xml",
                                                                                                                                                                                                project_name: nil,
                                                                                                                                                                                                dependencies: [],
                                                                                                                                                                                                kind: "lockfile",
                                                                                                                                                                                                success: true,
                                                                                                                                                                                              })
  end

  it "handles unmapped json component" do
    expect(described_class.analyse_contents("cyclonedx.json", %({ "components": [{ "purl": "#{unmapped_component}" }] }))).to eq({
                                                                                                                                   parser: "cyclonedx",
                                                                                                                                   path: "cyclonedx.json",
                                                                                                                                   project_name: nil,
                                                                                                                                   dependencies: [],
                                                                                                                                   kind: "lockfile",
                                                                                                                                   success: true,
                                                                                                                                 })
  end

  it "handles unmapped xml component" do
    expect(described_class.analyse_contents("cyclonedx.xml", %(<?xml version="1.0" encoding="UTF-8"?><bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq({
                                                                                                                                                                                                                                                          parser: "cyclonedx",
                                                                                                                                                                                                                                                          path: "cyclonedx.xml",
                                                                                                                                                                                                                                                          project_name: nil,
                                                                                                                                                                                                                                                          dependencies: [],
                                                                                                                                                                                                                                                          kind: "lockfile",
                                                                                                                                                                                                                                                          success: true,
                                                                                                                                                                                                                                                        })
  end

  it "handles no xml pragma" do
    expect(described_class.analyse_contents("cyclonedx.xml", %(<bom xmlns="http://cyclonedx.org/schema/bom/1.4"><components><component><purl>#{unmapped_component}</purl></component></components></bom>))).to eq({
                                                                                                                                                                                                                    parser: "cyclonedx",
                                                                                                                                                                                                                    path: "cyclonedx.xml",
                                                                                                                                                                                                                    project_name: nil,
                                                                                                                                                                                                                    dependencies: [],
                                                                                                                                                                                                                    kind: "lockfile",
                                                                                                                                                                                                                    success: true,
                                                                                                                                                                                                                  })
  end

  describe "ManifestEntries#parse!" do
    it "should not mutate the manifest sent in" do
      queue = [1, 2, 3]

      entries = described_class::ManifestEntries.new(parse_queue: queue)

      entries.parse! do |_item, _parse_queue|
        nil
      end

      expect(queue.count).to eq(3)
    end
  end

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
        version: "1.0.0",
      },
      {
        platform: :go,
        name: "cloud.google.com/go",
        version: "v0.38.0",
      },
      {
        platform: :maven,
        name: "org.hdrhistogram:HdrHistogram",
        version: "2.1.9",
      },
    ]
  end

  it "parses dependencies from cyclonedx.json" do
    result = described_class.analyse_contents("cyclonedx.json", load_fixture("cyclonedx.json"))

    artifactory_dependencies.each do |dependency|
      expect(result[:dependencies].find { |d| d.name == dependency[:name] }).to eq(Bibliothecary::Dependency.new(
                                                                                     platform: dependency[:platform].to_s,
                                                                                     name: dependency[:name],
                                                                                     requirement: dependency[:version],
                                                                                     type: "lockfile",
                                                                                     source: "cyclonedx.json"
                                                                                   ))
    end
  end

  it "parses deeply nested dependencies from cyclonedx.json" do
    result = described_class.analyse_contents("cyclonedx.json", load_fixture("cyclonedx-nested.json"))

    artifactory_dependencies.each do |dependency|
      expect(result[:dependencies].find { |d| d.name == dependency[:name] }).to eq(Bibliothecary::Dependency.new(
                                                                                     platform: dependency[:platform].to_s,
                                                                                     name: dependency[:name],
                                                                                     requirement: dependency[:version],
                                                                                     type: "lockfile",
                                                                                     source: "cyclonedx.json"
                                                                                   ))
    end
  end

  it "parses dependencies from cyclonedx.xml" do
    result = described_class.analyse_contents("cyclonedx.xml", load_fixture("cyclonedx.xml"))

    artifactory_dependencies.each do |dependency|
      expect(result[:dependencies].find { |d| d.name == dependency[:name] }).to eq(Bibliothecary::Dependency.new(
                                                                                     platform: dependency[:platform].to_s,
                                                                                     name: dependency[:name],
                                                                                     requirement: dependency[:version],
                                                                                     type: "lockfile",
                                                                                     source: "cyclonedx.xml"
                                                                                   ))
    end
  end

  it "parses deeply nested dependencies from cyclonedx.xml" do
    result = described_class.analyse_contents("cyclonedx.xml", load_fixture("cyclonedx-nested.xml"))

    artifactory_dependencies.each do |dependency|
      expect(result[:dependencies].find { |d| d.name == dependency[:name] }).to eq(Bibliothecary::Dependency.new(
                                                                                     platform: dependency[:platform].to_s,
                                                                                     name: dependency[:name],
                                                                                     requirement: dependency[:version],
                                                                                     type: "lockfile",
                                                                                     source: "cyclonedx.xml"
                                                                                   ))
    end
  end

  context "with cache" do
    let(:options) { { cache: {} } }

    it "uses the cache for json" do
      described_class.analyse_contents("cyclonedx.json", load_fixture("cyclonedx.json"), options:)

      expect(options[:cache]["cyclonedx.json"]).not_to eq(nil)
    end

    it "uses the cache for xml" do
      described_class.analyse_contents("cyclonedx.xml", load_fixture("cyclonedx.xml"), options:)

      expect(options[:cache]["cyclonedx.xml"]).not_to eq(nil)
    end
  end
end
