require "spec_helper"

describe Bibliothecary::Parsers::PreCommit do
    it "has a platform name" do
        expect(described_class.platform_name).to eq("precommit")
    end

    it "parses dependencies from .pre-commit-config.yaml" do
        expect(described_class.analyse_contents(".pre-commit-config.yaml", load_fixture(".pre-commit-config.yaml"))).to eq({
          :platform=>"precommit",
          :path=>".pre-commit-config.yaml",
          :dependencies=>[
            {:name=>"check-yaml", :requirement=>"v2.3.0", :type=>"runtime"},
            {:name=>"end-of-file-fixer", :requirement=>"v2.3.0", :type=>"runtime"},
            {:name=>"trailing-whitespace", :requirement=>"v2.3.0", :type=>"runtime"},
            {:name=>"black", :requirement=>"19.3b0", :type=>"runtime"},
          ],
          kind: 'manifest',
          success: true,
        })
    end

    it "parses dependencies from .pre-commit-config.yaml without repos" do
        expect(described_class.analyse_contents(".pre-commit-config.yaml", load_fixture("broken/.pre-commit-config_repos.yaml"))).to eq({
          :platform=>"precommit",
          :path=>".pre-commit-config.yaml",
          :dependencies=>[],
          kind: 'manifest',
          success: true,
        })
    end

    it "parses dependencies from .pre-commit-config.yaml without hooks" do
        expect(described_class.analyse_contents(".pre-commit-config.yaml", load_fixture("broken/.pre-commit-config_hooks.yaml"))).to eq({
          :platform=>"precommit",
          :path=>".pre-commit-config.yaml",
          :dependencies=>[],
          kind: 'manifest',
          success: true,
        })
    end
end
