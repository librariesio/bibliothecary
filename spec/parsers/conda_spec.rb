require 'spec_helper'

describe Bibliothecary::Parsers::Conda do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('conda')
  end

  it 'parses dependencies from environment.yml', :vcr do
    expect(described_class.analyse_contents('environment.yml', load_fixture('environment.yml'))).to eq([
      {
        :platform=>"conda",
        :path=>"environment.yml",
        :dependencies=>[
          {:name=>"beautifulsoup4", :requirement=>"4.7.1", :type=>"runtime"},
          {:name=>"biopython", :requirement=>"1.74", :type=>"runtime"},
          {:name=>"certifi", :requirement=>"2019.6.16", :type=>"runtime"},
          {:name=>"ncurses", :requirement=>"6.1", :type=>"runtime"},
          {:name=>"numpy", :requirement=>"1.16.4", :type=>"runtime"},
          {:name=>"openssl", :requirement=>"1.1.1c", :type=>"runtime"},
          {:name=>"pip", :requirement=>"19.2.2", :type=>"runtime"},
          {:name=>"python", :requirement=>"3.7.3", :type=>"runtime"},
          {:name=>"readline", :requirement=>"7.0", :type=>"runtime"},
          {:name=>"setuptools", :requirement=>"41.0.1", :type=>"runtime"},
          {:name=>"sqlite", :requirement=>"3.29.0", :type=>"runtime"}
        ],
        kind: "manifest",
        success: true
      },
      {
       :platform=>"conda",
       :path=>"environment.yml",
       :dependencies=>[
           {:name=>"_libgcc_mutex", :requirement=>"0.1", :type=>"runtime"},
           {:name=>"beautifulsoup4", :requirement=>"4.7.1", :type=>"runtime"},
           {:name=>"biopython", :requirement=>"1.74", :type=>"runtime"},
           {:name=>"blas", :requirement=>"1.0", :type=>"runtime"},
           {:name=>"ca-certificates", :requirement=>"2019.5.15", :type=>"runtime"},
           {:name=>"certifi", :requirement=>"2019.6.16", :type=>"runtime"},
           {:name=>"intel-openmp", :requirement=>"2019.4", :type=>"runtime"},
           {:name=>"libedit", :requirement=>"3.1.20181209", :type=>"runtime"},
           {:name=>"libffi", :requirement=>"3.2.1", :type=>"runtime"},
           {:name=>"libgcc-ng", :requirement=>"9.1.0", :type=>"runtime"},
           {:name=>"libgfortran-ng", :requirement=>"7.3.0", :type=>"runtime"},
           {:name=>"libstdcxx-ng", :requirement=>"9.1.0", :type=>"runtime"},
           {:name=>"mkl", :requirement=>"2019.4", :type=>"runtime"},
           {:name=>"mkl-service", :requirement=>"2.0.2", :type=>"runtime"},
           {:name=>"mkl_fft", :requirement=>"1.0.14", :type=>"runtime"},
           {:name=>"mkl_random", :requirement=>"1.0.2", :type=>"runtime"},
           {:name=>"ncurses", :requirement=>"6.1", :type=>"runtime"},
           {:name=>"numpy", :requirement=>"1.16.4", :type=>"runtime"},
           {:name=>"numpy-base", :requirement=>"1.16.4", :type=>"runtime"},
           {:name=>"openssl", :requirement=>"1.1.1c", :type=>"runtime"},
           {:name=>"pip", :requirement=>"19.2.2", :type=>"runtime"},
           {:name=>"python", :requirement=>"3.7.3", :type=>"runtime"},
           {:name=>"readline", :requirement=>"7.0", :type=>"runtime"},
           {:name=>"setuptools", :requirement=>"41.0.1", :type=>"runtime"},
           {:name=>"six", :requirement=>"1.12.0", :type=>"runtime"},
           {:name=>"soupsieve", :requirement=>"1.9.2", :type=>"runtime"},
           {:name=>"sqlite", :requirement=>"3.29.0", :type=>"runtime"},
           {:name=>"tk", :requirement=>"8.6.8", :type=>"runtime"},
           {:name=>"wheel", :requirement=>"0.33.4", :type=>"runtime"},
           {:name=>"xz", :requirement=>"5.2.4", :type=>"runtime"},
           {:name=>"zlib", :requirement=>"1.2.11", :type=>"runtime"}
         ],
         kind: "lockfile",
         success: true
       }
      ]
    )
  end

  it 'parses dependencies from environment.yml with pip', :vcr do
    expect(described_class.analyse_contents('conda_with_pip/environment.yml', load_fixture('conda_with_pip/environment.yml'))).to eq([
       {
           :platform=>"conda",
           :path=>"conda_with_pip/environment.yml",
           :dependencies=>[
               {:name=>"pip", :requirement=>"19.2.2", :type=>"runtime"},
               {:name=>"sqlite", :requirement=>"3.29.0", :type=>"runtime"}
           ],
           kind: "manifest",
           success: true
       },
       {
           :platform=>"conda",
           :path=>"conda_with_pip/environment.yml",
           :dependencies=>[
               {:name=>"_libgcc_mutex", :requirement=>"0.1", :type=>"runtime"},
               {:name=>"ca-certificates", :requirement=>"2019.5.15", :type=>"runtime"},
               {:name=>"certifi", :requirement=>"2019.6.16", :type=>"runtime"},
               {:name=>"libedit", :requirement=>"3.1.20181209", :type=>"runtime"},
               {:name=>"libffi", :requirement=>"3.2.1", :type=>"runtime"},
               {:name=>"libgcc-ng", :requirement=>"9.1.0", :type=>"runtime"},
               {:name=>"libstdcxx-ng", :requirement=>"9.1.0", :type=>"runtime"},
               {:name=>"ncurses", :requirement=>"6.1", :type=>"runtime"},
               {:name=>"openssl", :requirement=>"1.1.1c", :type=>"runtime"},
               {:name=>"pip", :requirement=>"19.2.2", :type=>"runtime"},
               {:name=>"python", :requirement=>"3.7.4", :type=>"runtime"},
               {:name=>"readline", :requirement=>"7.0", :type=>"runtime"},
               {:name=>"setuptools", :requirement=>"41.0.1", :type=>"runtime"},
               {:name=>"sqlite", :requirement=>"3.29.0", :type=>"runtime"},
               {:name=>"tk", :requirement=>"8.6.8", :type=>"runtime"},
               {:name=>"wheel", :requirement=>"0.33.4", :type=>"runtime"},
               {:name=>"xz", :requirement=>"5.2.4", :type=>"runtime"},
               {:name=>"zlib", :requirement=>"1.2.11", :type=>"runtime"},
           ],
           kind: "lockfile",
           success: true
       },
       {
           :platform=>"pypi",
           :path=>"conda_with_pip/environment.yml",
           :dependencies=>[
               {:name=>"urllib3", :requirement=>"*", :type=>"runtime"},
               {:name=>"Django", :requirement=>"==2.0.0", :type=>"runtime"},

           ],
           kind: "manifest",
           success: true
       }
   ]
  )
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('environment.yml')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('test/foo/aenvironment.yml')).to be_falsey
  end
end
