# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "pub_suber/tasks"

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop)

task default: [:spec, :rubocop]
