# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Packagist do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("packagist")
  end

  it "parses dependencies from composer.json" do
    expect(described_class.analyse_contents("composer.json", load_fixture("composer.json"))).to eq({
                                                                                                     platform: "packagist",
                                                                                                     path: "composer.json",
                                                                                                     dependencies: [
        Bibliothecary::Dependency.new(platform: "packagist", name: "laravel/framework", requirement: "5.0.*", type: "runtime", source: "composer.json"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "drupal/address", requirement: "^1.0", type: "runtime", source: "composer.json"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "phpunit/phpunit", requirement: "~4.0", type: "development", source: "composer.json"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "phpspec/phpspec", requirement: "~2.1", type: "development", source: "composer.json"),
      ],
                                                                                                     kind: "manifest",
                                                                                                     success: true,
                                                                                                   })
  end

  it "parses dependencies from composer.lock" do
    expect(described_class.analyse_contents("composer.lock", load_fixture("composer.lock"))).to eq({
                                                                                                     platform: "packagist",
                                                                                                     path: "composer.lock",
                                                                                                     dependencies: [
        Bibliothecary::Dependency.new(platform: "packagist", name: "doctrine/annotations", requirement: "v1.2.1", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "doctrine/cache", requirement: "v1.3.1", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "doctrine/collections", requirement: "v1.2", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "drupal/address", requirement: "8.x-1.9", original_requirement: "1.9.0", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "symfony/monolog-bundle", requirement: "v2.6.1", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "symfony/swiftmailer-bundle", requirement: "v2.3.8", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "symfony/symfony", requirement: "v2.6.1", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "twig/extensions", requirement: "v1.2.0", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "twig/twig", requirement: "v1.16.2", type: "runtime", source: "composer.lock"),
        Bibliothecary::Dependency.new(platform: "packagist", name: "sensio/generator-bundle", requirement: "v2.5.0", type: "development", source: "composer.lock"),
      ],
                                                                                                     kind: "lockfile",
                                                                                                     success: true,
                                                                                                   })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("composer.json")).to be_truthy
    expect(described_class.match?("composer.lock")).to be_truthy
  end
end
