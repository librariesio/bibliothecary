require "spec_helper"

describe Bibliothecary::MultiParsers::DependenciesCSV, :focus do
  let!(:parser_class) do
    k = Class.new do
      def platform_name; "whatever"; end
    end

    k.send(:include, described_class)
    k
  end

  let(:parser) { parser_class.new }
  let(:options) do
    { cache: {}, filename: "dependencies.csv" }
  end

  context "with missing headers" do
    let!(:csv) do
      <<-CSV
cat,dog,version
meow,woof,2.2.0
      CSV
    end

    it "raises an error" do
      expect { parser.parse_dependencies_csv(csv, options: options) }.to raise_error(/Missing required headers platform, name/)
    end
  end

  context "missing field" do
    let!(:csv) do
      <<-CSV
platform,name,version
meow,wow,2.2.0
,wow,2.2.0
      CSV
    end

    it "raises an error" do
      expect { parser.parse_dependencies_csv(csv, options: options) }.to raise_error(/Missing required field 'platform' on line 3/)
    end
  end

  context "two columns that can match" do
    let!(:csv) do
      <<-CSV
platform,name,version,lockfile requirement
meow,wow,2.2.0,6.0.0
raow,wow,2.2.0,6.0.0
      CSV
    end

    it "raises selects the highest priority match" do
      allow(parser).to receive(:platform_name).and_return("raow")

      result = parser.parse_dependencies_csv(csv, options: options)

      expect(result.first.requirement).to eq("6.0.0")
    end
  end

  context "all data ok" do
    context "original field names" do
      let!(:csv) do
        <<-CSV
platform,name,version,type
meow,wow,2.2.0,bird
hiss,wow,2.2.0,
hiss,raow,2.2.1,bird
        CSV
      end

      it "parses, filters, and caches" do
        allow(parser).to receive(:platform_name).and_return("hiss")

        result = parser.parse_dependencies_csv(csv, options: options)

        expect(result).to eq([
          Bibliothecary::Dependency.new(platform: "hiss", name: "wow", requirement: "2.2.0", type: "runtime", source: "dependencies.csv"),
          Bibliothecary::Dependency.new(platform: "hiss", name: "raow", requirement: "2.2.1", type: "bird", source: "dependencies.csv"),
        ])

        # the cache should contain a CSVFile
        expect(options[:cache][options[:filename]].result.length).to eq(3)
      end
    end

    context "Tidelift export field names" do
      context "without fallback" do
        let!(:csv) do
          <<-CSV
Platform,Name,Lockfile Requirement,Lockfile Type,Manifest Requirement
meow,wow,2.2.0,bird,
hiss,wow,2.2.0,,= 2.2.0
hiss,raow,2.2.1,bird,
          CSV
        end

        it "parses, filters, and caches" do
          allow(parser).to receive(:platform_name).and_return("hiss")

          result = parser.parse_dependencies_csv(csv, options: options)

          expect(result).to eq([
            Bibliothecary::Dependency.new(platform: "hiss", name: "wow", type: "runtime", requirement: "2.2.0", source: "dependencies.csv"),
            Bibliothecary::Dependency.new(platform: "hiss", name: "raow", type: "bird", requirement: "2.2.1", source: "dependencies.csv"),
          ])

          # the cache should contain a CSVFile
          expect(options[:cache][options[:filename]].result.length).to eq(3)
        end
      end

      context "with fallback" do
        let!(:csv) do
          <<-CSV
Platform,Name,Lockfile Requirement,Lockfile Type,Version
meow,wow,2.2.0,bird,2.2.0
hiss,wow,2.2.0,,2.2.0
hiss,raow,2.2.0,bird,2.2.1
          CSV
        end

        it "parses, filters, and caches" do
          allow(parser).to receive(:platform_name).and_return("hiss")

          result = parser.parse_dependencies_csv(csv, options: options)

          expect(result).to eq([
            Bibliothecary::Dependency.new(platform: "hiss", name: "wow", type: "runtime", requirement: "2.2.0", source: "dependencies.csv"),
            # headers are searched left to right for each field, and the
            # highest priority matching one wins
            Bibliothecary::Dependency.new(platform: "hiss", name: "raow", type: "bird", requirement: "2.2.0", source: "dependencies.csv"),
          ])

          # the cache should contain a CSVFile
          expect(options[:cache][options[:filename]].result.length).to eq(3)
        end
      end
    end
  end
end
