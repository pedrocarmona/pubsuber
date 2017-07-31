# frozen_string_literal: true
# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pub_suber/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = "pub_suber"
  spec.version       = PubSuber::VERSION
  spec.authors       = ["Pedro"]
  spec.email         = ["tech@bidmath.com"]

  spec.summary       = %(Background jobs with PubSub.)
  spec.description   = %(
    Ruby asynchronous background jobs using PubSub.
    Uses messages as jobs and topics as queues to distribute jobs between workers.
  )
  spec.homepage      = "http://pedrocarmona.github.io/pubsuber"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = ""
  else
    fail "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files =
    `git ls-files -z`
    .split("\x0")
    .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "google-cloud-pubsub"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rubocop", "~> 0.46"
  spec.add_development_dependency "simplecov", "~> 0.12"
end
