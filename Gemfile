# frozen_string_literal: true

source "https://rubygems.org"

# Temporarily pegging to HEAD until 0.2.1 is released: https://github.com/piotrmurach/strings-ansi/pull/2
gem "strings-ansi", ref: "35d0c9430cf0a8022dc12bdab005bce296cb9f00", github: "piotrmurach/strings-ansi"

# Ruby 3.4+ no longer includes these as default gems
gem "base64"
gem "benchmark"
gem "bigdecimal"
gem "csv"
gem "logger"
gem "ostruct"

# Specify your gem's dependencies in bibliothecary.gemspec
gemspec

group :development do
  gem "pry"
end

group :development, :test do
  gem "rake", "~> 13.0"
  gem "rubocop", "~> 1.71"
  gem "rubocop-rails"
  gem "rubocop-rake" # This is needed by packageurl-ruby, until it reclassifies it as a dev dependency.
end

group :test do
  gem "rspec", "~> 3.0"
  gem "simplecov"
  gem "super_diff", "~> 0.18.0"
  gem "webmock"
end
