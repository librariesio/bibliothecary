require 'spec_helper'

describe Bibliothecary::Parsers::Conda do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('conda')
  end

  it 'parses dependencies from environment.yml', :vcr do
    expect(described_class.analyse_contents('environment.yml', load_fixture('environment.yml'))).to eq({
      :platform=>"conda",
      :path=>"environment.yml",
      :dependencies=>{
        :channels=>["defaults"],
        :lockfile=>[
          {:name=>"_libgcc_mutex", :requirement=>"0.1"},
          {:name=>"beautifulsoup4", :requirement=>"4.7.1"},
          {:name=>"biopython", :requirement=>"1.74"},
          {:name=>"blas", :requirement=>"1.0"},
          {:name=>"ca-certificates", :requirement=>"2019.5.15"},
          {:name=>"certifi", :requirement=>"2019.6.16"},
          {:name=>"intel-openmp", :requirement=>"2019.4"},
          {:name=>"libedit", :requirement=>"3.1.20181209"},
          {:name=>"libffi", :requirement=>"3.2.1"},
          {:name=>"libgcc-ng", :requirement=>"9.1.0"},
          {:name=>"libgfortran-ng", :requirement=>"7.3.0"},
          {:name=>"libstdcxx-ng", :requirement=>"9.1.0"},
          {:name=>"mkl", :requirement=>"2019.4"},
          {:name=>"mkl-service", :requirement=>"2.0.2"},
          {:name=>"mkl_fft", :requirement=>"1.0.14"},
          {:name=>"mkl_random", :requirement=>"1.0.2"},
          {:name=>"ncurses", :requirement=>"6.1"},
          {:name=>"numpy", :requirement=>"1.16.4"},
          {:name=>"numpy-base", :requirement=>"1.16.4"},
          {:name=>"openssl", :requirement=>"1.1.1c"},
          {:name=>"pip", :requirement=>"19.2.2"},
          {:name=>"python", :requirement=>"3.7.3"},
          {:name=>"readline", :requirement=>"7.0"},
          {:name=>"setuptools", :requirement=>"41.0.1"},
          {:name=>"six", :requirement=>"1.12.0"},
          {:name=>"soupsieve", :requirement=>"1.9.2"},
          {:name=>"sqlite", :requirement=>"3.29.0"},
          {:name=>"tk", :requirement=>"8.6.8"},
          {:name=>"wheel", :requirement=>"0.33.4"},
          {:name=>"xz", :requirement=>"5.2.4"},
          {:name=>"zlib", :requirement=>"1.2.11"}],
        :manifest=>[
          {:name=>"beautifulsoup4", :requirement=>"4.7.1"},
          {:name=>"biopython", :requirement=>"1.74"},
          {:name=>"certifi", :requirement=>"2019.6.16"},
          {:name=>"ncurses", :requirement=>"6.1"},
          {:name=>"numpy", :requirement=>"1.16.4"},
          {:name=>"openssl", :requirement=>"1.1.1c"},
          {:name=>"pip", :requirement=>"19.2.2"},
          {:name=>"python", :requirement=>"3.7.3"},
          {:name=>"readline", :requirement=>"7.0"},
          {:name=>"setuptools", :requirement=>"41.0.1"},
          {:name=>"sqlite", :requirement=>"3.29.0"}
        ]
      },
      kind: 'manifest',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('environment.yml')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('test/foo/aenvironment.yml')).to be_falsey
  end
end
