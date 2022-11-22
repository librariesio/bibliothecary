require 'spec_helper'

describe DockerfileParser do
  it 'parses simple from statements' do
    dockerfile = <<-EOF
      FROM ubuntu:14.04
    EOF

    expect(described_class.new(dockerfile).parse).to eq([
      {
        name: 'ubuntu',
        requirement: '14.04',
        type: 'build'
      }
    ])
  end

  it 'parses from statements with platform' do
    dockerfile = <<-EOF
      FROM --platform=linux ubuntu:14.04
    EOF

    expect(described_class.new(dockerfile).parse).to eq([
      {
        name: 'ubuntu',
        requirement: '14.04',
        type: 'build'
      }
    ])
  end

  it 'parses from statements with comments' do
    dockerfile = <<-EOF
      FROM ubuntu:14.04 # This is a comment
    EOF

    expect(described_class.new(dockerfile).parse).to eq([
      {
        name: 'ubuntu',
        requirement: '14.04',
        type: 'build'
      }
    ])
  end

  it 'parses from statements with no version' do
    dockerfile = <<-EOF
      FROM ubuntu
    EOF

    expect(described_class.new(dockerfile).parse).to eq([
      {
        name: 'ubuntu',
        requirement: 'latest',
        type: 'build'
      }
    ])
  end
end