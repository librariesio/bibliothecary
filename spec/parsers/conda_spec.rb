require "spec_helper"

describe Bibliothecary::Parsers::Conda do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("conda")
  end

  it "parses dependencies from environment.yml", :vcr do
    expect(described_class.analyse_contents("environment.yml", load_fixture("environment.yml"))).to eq(
      {
        platform: "conda",
        path: "environment.yml",
        dependencies: [
          Bibliothecary::Dependency.new(name: "beautifulsoup4", requirement: "4.7.1", type: "runtime"),
          Bibliothecary::Dependency.new(name: "biopython", requirement: "1.74", type: "runtime"),
          Bibliothecary::Dependency.new(name: "certifi", requirement: "2019.6.16", type: "runtime"),
          Bibliothecary::Dependency.new(name: "ncurses", requirement: "6.1", type: "runtime"),
          Bibliothecary::Dependency.new(name: "numpy", requirement: "1.16.4", type: "runtime"),
          Bibliothecary::Dependency.new(name: "openssl", requirement: "1.1.1c", type: "runtime"),
          Bibliothecary::Dependency.new(name: "pip", requirement: "", type: "runtime"),
          Bibliothecary::Dependency.new(name: "python", requirement: "3.7.3", type: "runtime"),
          Bibliothecary::Dependency.new(name: "readline", requirement: "7.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "setuptools", requirement: "", type: "runtime"),
          Bibliothecary::Dependency.new(name: "sqlite", requirement: "3.29.0", type: "runtime"),
        ],
        kind: "manifest",
        success: true,
      }
    )
  end

  it "parses dependencies from environment.yml.lock", :vcr do
    expect(described_class.analyse_contents("environment.yml.lock", load_fixture("environment.yml"))).to eq(
      {
       platform: "conda",
       path: "environment.yml.lock",
       dependencies: [
          Bibliothecary::Dependency.new(name: "_libgcc_mutex", requirement: "0.1", type: "runtime"),
          Bibliothecary::Dependency.new(name: "beautifulsoup4", requirement: "4.7.1", type: "runtime"),
          Bibliothecary::Dependency.new(name: "biopython", requirement: "1.74", type: "runtime"),
          Bibliothecary::Dependency.new(name: "blas", requirement: "1.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "ca-certificates", requirement: "2019.8.28", type: "runtime"),
          Bibliothecary::Dependency.new(name: "certifi", requirement: "2019.6.16", type: "runtime"),
          Bibliothecary::Dependency.new(name: "intel-openmp", requirement: "2019.4", type: "runtime"),
          Bibliothecary::Dependency.new(name: "libedit", requirement: "3.1.20181209", type: "runtime"),
          Bibliothecary::Dependency.new(name: "libffi", requirement: "3.2.1", type: "runtime"),
          Bibliothecary::Dependency.new(name: "libgcc-ng", requirement: "9.1.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "libgfortran-ng", requirement: "7.3.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "libstdcxx-ng", requirement: "9.1.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "mkl", requirement: "2019.4", type: "runtime"),
          Bibliothecary::Dependency.new(name: "mkl-service", requirement: "2.3.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "mkl_fft", requirement: "1.0.14", type: "runtime"),
          Bibliothecary::Dependency.new(name: "mkl_random", requirement: "1.1.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "ncurses", requirement: "6.1", type: "runtime"),
          Bibliothecary::Dependency.new(name: "numpy", requirement: "1.16.4", type: "runtime"),
          Bibliothecary::Dependency.new(name: "numpy-base", requirement: "1.16.4", type: "runtime"),
          Bibliothecary::Dependency.new(name: "openssl", requirement: "1.1.1c", type: "runtime"),
          Bibliothecary::Dependency.new(name: "pip", requirement: "19.2.3", type: "runtime"),
          Bibliothecary::Dependency.new(name: "python", requirement: "3.7.3", type: "runtime"),
          Bibliothecary::Dependency.new(name: "readline", requirement: "7.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "setuptools", requirement: "41.2.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "six", requirement: "1.12.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "soupsieve", requirement: "1.9.3", type: "runtime"),
          Bibliothecary::Dependency.new(name: "sqlite", requirement: "3.29.0", type: "runtime"),
          Bibliothecary::Dependency.new(name: "tk", requirement: "8.6.8", type: "runtime"),
          Bibliothecary::Dependency.new(name: "wheel", requirement: "0.33.6", type: "runtime"),
          Bibliothecary::Dependency.new(name: "xz", requirement: "5.2.4", type: "runtime"),
          Bibliothecary::Dependency.new(name: "zlib", requirement: "1.2.11", type: "runtime"),
         ],
         kind: "lockfile",
         success: true,
       }
    )
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("environment.yml")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("test/foo/aenvironment.yml")).to be_falsey
  end
end
