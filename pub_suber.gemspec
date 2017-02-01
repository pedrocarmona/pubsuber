# frozen_string_literal: true
# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pub_suber/version"

Gem::Specification.new do |spec|
  spec.name          = "pub_suber"
  spec.version       = PubSuber::VERSION
  spec.authors       = ["Pedro"]
  spec.email         = ["tech@bidmath.com"]

  spec.summary       = %{Background jobs with PubSub.}
  spec.description   = %{
    Ruby asynchronous background jobs using PubSub messages and topics
    to distribute jobs between workers.
  }
  spec.homepage      = "http://pedrocarmona.github.io/pubsuber"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
