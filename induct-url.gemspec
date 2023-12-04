# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "induct-url"
  spec.version = "0.0.0.beta1"
  spec.authors = ["ingemar"]
  spec.email = ["ingemar@xox.se"]

  spec.summary = "A URL parser and constructor that works as you expect"
  spec.description = <<~DESC
    INDUCT-URL is a simple URL parser and construction tool for Ruby. It doesn't follow any RFC, instead, it behaves as you expect.
  DESC
  spec.homepage = "https://github.com/ingemar/induct-url"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://example.com"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "CHANGELOG", "LICENSE", "README.md"]

  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 2.0", "< 4.0"
end
