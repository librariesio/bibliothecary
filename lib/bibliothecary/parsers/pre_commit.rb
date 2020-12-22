require "yaml"

module Bibliothecary
    module Parsers
        class PreCommit
            include Bibliothecary::Analyser

            def self.mapping
                {
                    match_filename(".pre-commit-config.yaml") => {
                        kind: "manifest",
                        parser: :parser_manifest,
                    }
                }
            end

            def self.parser_manifest(file_contents)
                manifest = YAML.load(file_contents)

                return [] unless manifest
                return [] unless manifest["repos"]

                manifest["repos"].map do |repo|
                    if (
                        repo["repo"] and
                        repo["rev"] and
                        repo["hooks"] and
                        not ["meta", "local"].include?(repo["repo"])
                    )
                        repo.fetch("hooks", []).map do |hook|
                            {
                                name: hook["id"],
                                requirement: repo["rev"],
                                type: "runtime",
                            }
                        end
                    else
                        []
                    end
                end.flatten
            end
        end
    end
end
