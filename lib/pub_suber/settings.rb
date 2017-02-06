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
    FAILED_JOBS_QUEUE_NAME = "failed"

    attr_accessor :project_id, :logger, :max_attempts, :sleep_delay, 
                  :message_deadline, :failed_jobs_queue_name

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = LOG_LEVEL
      @sleep_delay = SLEEP_DELAY
      @max_attempts = MAX_ATTEMPTS
      @message_deadline = MESSAGE_DEADLINE
      @failed_jobs_queue_name = FAILED_JOBS_QUEUE_NAME
    end
  end
  Settings = SettingsSingleton.instance
end
