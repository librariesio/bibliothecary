# frozen_string_literal: true

RSpec.shared_examples "dependencies.csv" do
  describe "dependencies.csv" do
    let!(:csv_dependencies) do
      [
        {
          platform: "maven",
          name: "com.example:something",
          version: "1.0.3",
          type: "runtime",
        },
        {
          platform: "maven",
          name: "com.example:something-dev",
          version: "1.0.4",
          type: "development",
        },
        ]
    end

    let(:dependencies_for_platform) do
      csv_dependencies.find_all { |d| d[:platform] == described_class.platform_name }.tap { |o| raise "This platform is not configured for testing with CycloneDX!" if o.empty? }
    end

    it "parses dependencies from cyclonedx.json" do
      result = described_class.analyse_contents("dependencies.csv", load_fixture("dependencies.csv"))

      dependencies_for_platform.each do |dependency|
        expect(result[:dependencies].find { |d| d.name == dependency[:name] }).to eq(Bibliothecary::Dependency.new(
                                                                                       platform: dependency[:platform],
                                                                                       name: dependency[:name],
                                                                                       requirement: dependency[:version],
                                                                                       type: dependency[:type],
                                                                                       source: "dependencies.csv"
                                                                                     ))
      end
    end
  end
end
