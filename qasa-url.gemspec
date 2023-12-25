# frozen_string_literal: true

require_relative "lib/qasa/url/version"

Gem::Specification.new do |spec|
  spec.name = "qasa-url"
  spec.version = Qasa::Url::VERSION
  spec.authors = ["ingemar"]
  spec.email = ["ingemar@xox.se"]

  spec.summary = "A simple URL parser and construction tool"
  spec.description = <<~DESC
    URL is a simple URL parser and construction tool for Ruby. It doesn't follow any RFC, instead, it behaves as you expect.
  DESC
  spec.homepage = "https://github.com/qasase/qasa-url"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "CHANGELOG", "LICENSE", "README.md"]

  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 2.0", "< 4.0"
end
