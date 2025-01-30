# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in bibliothecary.gemspec
gemspec

group :development do
  gem "pry"
end

group :development, :test do
  gem "rake", "~> 12.0"
  gem "rubocop", "~> 1.71"
  gem "rubocop-rails"
end

group :test do
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "simplecov"
  gem "webmock"
  gem "rspec", "~> 3.0"
end
