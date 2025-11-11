require 'spec_helper'

describe Bibliothecary::Parsers::Ollama do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('ollama')
  end

  it 'parses dependencies from Modelfile' do
    expect(described_class.analyse_contents('Modelfile', load_fixture('Modelfile'))).to eq({
      :platform=>"ollama",
      :path=>"Modelfile",
      :dependencies=>[
        Bibliothecary::Dependency.new(platform: "ollama", name: "llama3.2", requirement: "latest", type: "runtime", source: "Modelfile")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from Modelfile with version tag' do
    expect(described_class.analyse_contents('Modelfile', load_fixture('Modelfile-tagged'))).to eq({
      :platform=>"ollama",
      :path=>"Modelfile",
      :dependencies=>[
        Bibliothecary::Dependency.new(platform: "ollama", name: "mistral", requirement: "7b-instruct", type: "runtime", source: "Modelfile")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from Modelfile with local GGUF file' do
    expect(described_class.analyse_contents('Modelfile', load_fixture('Modelfile-local'))).to eq({
      :platform=>"ollama",
      :path=>"Modelfile",
      :dependencies=>[
        Bibliothecary::Dependency.new(platform: "ollama", name: "my-custom-model.gguf", requirement: "local", type: "runtime", source: "Modelfile")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('Modelfile')).to be_truthy
    expect(described_class.match?('modelfile')).to be_falsey
    expect(described_class.match?('Dockerfile')).to be_falsey
  end
end
