# frozen_string_literal: true

require "singleton"
require "logger"

module PubSuber
  class SettingsSingleton
    include Singleton
    LOG_LEVEL = Logger::INFO
    # worker
    SLEEP_DELAY = 15
    MAX_ATTEMPTS = 3
    MESSAGE_DEADLINE = 600
    BURIED_JOBS_QUEUE_NAME = "buried"
    SUCESSFUL_JOBS_QUEUE_NAME = "sucessful"

    attr_accessor :project_id, :logger, :max_attempts, :sleep_delay,
                  :message_deadline, :buried_jobs_queue_name,
                  :sucessful_jobs_queue_name

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = LOG_LEVEL
      @sleep_delay = SLEEP_DELAY
      @max_attempts = MAX_ATTEMPTS
      @message_deadline = MESSAGE_DEADLINE
      @sucessful_jobs_queue_name = SUCESSFUL_JOBS_QUEUE_NAME
      @buried_jobs_queue_name = BURIED_JOBS_QUEUE_NAME
    end
  end
  Settings = SettingsSingleton.instance
end
