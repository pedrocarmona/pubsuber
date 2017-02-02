# frozen_string_literal: true

require "rspec/its"
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.bundle/"
end

require "pub_suber"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random

  Kernel.srand config.seed
end
