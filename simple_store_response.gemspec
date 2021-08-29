# frozen_string_literal: true

require_relative "lib/simple_store_response"

Gem::Specification.new do |s|
  s.name                  = "simple_store_response"
  s.version               = SimpleStoreResponse::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.5"
  s.summary               = "Simple CGI storage script response"
  s.description           = "CGI storage script response generator"
  s.authors               = ["juankman94"]
  s.email                 = "juan.carlos@hey.com"
  s.homepage              = "https://github.com/JuanKman94/ruby-cgi"
  s.license               = "MIT"
  s.files                 = Dir["lib/**/*.rb"]
end
