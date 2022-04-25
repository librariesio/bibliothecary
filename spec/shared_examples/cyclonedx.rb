RSpec.shared_examples 'CycloneDX' do
  describe 'CycloneDX' do
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

    let(:dependencies_for_platform) do
      artifactory_dependencies.find_all { |d| d[:platform] == described_class.platform_name.to_sym }.tap { |o| raise "This platform is not configured for testing with CycloneDX!" unless o.length > 0 }
    end

    it 'parses dependencies from cyclonedx.json' do
      result = described_class.analyse_contents('cyclonedx.json', load_fixture('cyclonedx.json'))

      dependencies_for_platform.each do |dependency|
        expect(result[:dependencies].find { |d| d[:name] == dependency[:name] }).to eq({
          name: dependency[:name],
          requirement: dependency[:version],
          type: 'lockfile'
        })
      end
    end

    it 'parses dependencies from cyclonedx.xml' do
      result = described_class.analyse_contents('cyclonedx.xml', load_fixture('cyclonedx.xml'))

      dependencies_for_platform.each do |dependency|
        expect(result[:dependencies].find { |d| d[:name] == dependency[:name] }).to eq({
          name: dependency[:name],
          requirement: dependency[:version],
          type: 'lockfile'
        })
      end
    end

    context 'with cache' do
      let(:options) { { cache: {} } }

      it 'uses the cache for json' do
        described_class.analyse_contents('cyclonedx.json', load_fixture('cyclonedx.json'), options: options)

        expect(options[:cache]['cyclonedx.json']).not_to eq(nil)
      end

      it 'uses the cache for xml' do
        described_class.analyse_contents('cyclonedx.xml', load_fixture('cyclonedx.xml'), options: options)

        expect(options[:cache]['cyclonedx.xml']).not_to eq(nil)
      end
    end
  end
end

