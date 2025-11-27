# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::MultiParsers::DependenciesCSV do
  it "has a platform name" do
    expect(described_class.parser_name).to eq("dependenciescsv")
  end

  let(:options) do
    { filename: "dependencies.csv" }
  end

  context "with missing headers" do
    let!(:csv) do
      <<~CSV
        cat,dog,version
        meow,woof,2.2.0
      CSV
    end

    it "raises an error" do
      expect { described_class.parse_dependencies_csv(csv) }.to raise_error(/Missing required headers platform, name/)
    end
  end

  context "missing field" do
    let!(:csv) do
      <<~CSV
        platform,name,version
        meow,wow,2.2.0
        ,wow,2.2.0
      CSV
    end

    it "raises an error" do
      expect { described_class.parse_dependencies_csv(csv) }.to raise_error(/Missing required field 'platform' on line 3/)
    end
  end

  context "two columns that can match" do
    let!(:csv) do
      <<~CSV
        platform,name,version,lockfile requirement
        npm,wow,2.2.0,6.0.0
        pypi,wow,2.2.0,5.0.0
      CSV
    end

    it "parses all platforms" do
      result = described_class.analyse_contents("dependencies.csv", csv)

      expect(result[:dependencies]).to contain_exactly(
        Bibliothecary::Dependency.new(platform: "npm", name: "wow", requirement: "6.0.0", type: "runtime", source: "dependencies.csv"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "wow", requirement: "5.0.0", type: "runtime", source: "dependencies.csv")
      )
    end
  end

  context "all data ok" do
    context "original field names" do
      let!(:csv) do
        <<~CSV
          platform,name,version,type
          npm,wow,2.2.0,development
          pypi,wow,2.2.0,
          pypi,raow,2.2.1,development
        CSV
      end

      it "parses all dependencies" do
        result = described_class.analyse_contents("dependencies.csv", csv)

        expect(result[:parser]).to eq("dependenciescsv")
        expect(result[:path]).to eq("dependencies.csv")
        expect(result[:dependencies]).to contain_exactly(
          Bibliothecary::Dependency.new(platform: "npm", name: "wow", requirement: "2.2.0", type: "development", source: "dependencies.csv"),
          Bibliothecary::Dependency.new(platform: "pypi", name: "wow", requirement: "2.2.0", type: "runtime", source: "dependencies.csv"),
          Bibliothecary::Dependency.new(platform: "pypi", name: "raow", requirement: "2.2.1", type: "development", source: "dependencies.csv")
        )
      end
    end

    context "Tidelift export field names" do
      context "without fallback" do
        let!(:csv) do
          <<~CSV
            Platform,Name,Lockfile Requirement,Lockfile Type,Manifest Requirement
            npm,wow,2.2.0,development,
            pypi,wow,2.2.0,,= 2.2.0
            pypi,raow,2.2.1,development,
          CSV
        end

        it "parses all dependencies" do
          result = described_class.analyse_contents("dependencies.csv", csv)

          expect(result[:dependencies]).to contain_exactly(
            Bibliothecary::Dependency.new(platform: "npm", name: "wow", type: "development", requirement: "2.2.0", source: "dependencies.csv"),
            Bibliothecary::Dependency.new(platform: "pypi", name: "wow", type: "runtime", requirement: "2.2.0", source: "dependencies.csv"),
            Bibliothecary::Dependency.new(platform: "pypi", name: "raow", type: "development", requirement: "2.2.1", source: "dependencies.csv")
          )
        end
      end

      context "with fallback" do
        let!(:csv) do
          <<~CSV
            Platform,Name,Lockfile Requirement,Lockfile Type,Version
            npm,wow,2.2.0,development,2.2.0
            pypi,wow,2.2.0,,2.2.0
            pypi,raow,2.2.0,development,2.2.1
          CSV
        end

        it "parses with requirement priority" do
          result = described_class.analyse_contents("dependencies.csv", csv)

          expect(result[:dependencies]).to contain_exactly(
            Bibliothecary::Dependency.new(platform: "npm", name: "wow", type: "development", requirement: "2.2.0", source: "dependencies.csv"),
            Bibliothecary::Dependency.new(platform: "pypi", name: "wow", type: "runtime", requirement: "2.2.0", source: "dependencies.csv"),
            # headers are searched left to right for each field, and the
            # highest priority matching one wins (Lockfile Requirement before Version)
            Bibliothecary::Dependency.new(platform: "pypi", name: "raow", type: "development", requirement: "2.2.0", source: "dependencies.csv")
          )
        end
      end
    end
  end
end
