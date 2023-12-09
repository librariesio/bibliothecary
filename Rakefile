require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run the linter"
task :lint do
  sh "bundle exec rubocop -P"
end

desc "Run the linter with autofix"
task :fix do
  sh "bundle exec rubocop -A"
end
