# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in bibliothecary.gemspec
gemspec

group :development do
  gem "pry"
end

group :development, :test do
  gem "rake", "~> 12.0"
  gem "rubocop", "~> 1.84"
  gem "rubocop-rails"
  gem "rubocop-rake" # This is needed by packageurl-ruby, until it reclassifies it as a dev dependency.
end

group :test do
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "rspec", "~> 3.0"
  gem "simplecov"
  gem "super_diff", "~> 0.15.0"
  gem "webmock"
end
