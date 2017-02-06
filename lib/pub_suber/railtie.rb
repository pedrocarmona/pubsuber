# frozen_string_literal: true

module PubSuber
  class Railtie < Rails::Railtie
    initializer :after_initialize do
      Settings.logger = Rails.logger
    end
    rake_tasks do
      load "pub_suber/tasks.rb"
    end
  end
end
