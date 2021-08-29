# frozen_string_literal: true

require "rake/clean"
require "rake/testtask"
require_relative "lib/simple_store_response"

NAME = "simple_store_response".freeze
CLEAN.include ["#{NAME}-*.gem"]

task default: %w[test]

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

desc "Package gem"
task package: [:clean] do |t|
  sh %{gem build #{NAME}.gemspec}
end

desc "Install gem"
task install: [:package] do |t|
  sh %{gem install #{NAME}-#{SimpleStoreResponse::VERSION}.gem}
end

desc "Run tests"
task :test
