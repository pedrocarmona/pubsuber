# frozen_string_literal: true

module PubSuber
  # TODO: should control the lifecycle (processing, failed,
  # buried, successful)
  # TODO: should save metrics, kind of job, status,
  # parse workflow file
  class Worker
    attr_accessor :sleep_delay, :queues, :name, :logger

    def initialize(options = {})
      options[:sleep_delay] =
        options.fetch(:sleep_delay, Settings.sleep_delay)
      @queues = options[:queues]
      @logger = Settings.logger
      @driver = Driver.new
      @name = "PubSuberWorker##{object_id}"
    end

    def start
      prepare_execution
      loop do
        single_run
        sleep(sleep_delay)
        break if stop_execution?
      end
      logger.info("Exiting #{name}")
    end

    def prepare_execution
      trap("TERM") do stop_execution end
      trap("INT") do stop_execution end
      logger.info("Starting #{name}")
      @exit = false
    end

    def stop_execution
      Thread.new do
        logger.info("Preparing exit #{name}")
      end
      @exit = true
    end

    def stop_execution?
      @exit
    end

    def single_run
      job = @driver.reserve_one_job(queues)
      if job
        invoke_job(job)
      else
        logger.info "No jobs to process"
      end
    end

    def invoke_job(job)
      performed = perform(job)
      if performed
        @driver.successful(job)
      elsif job.can_reschedule?
        @driver.reschedule(job)
      else
        @driver.bury(job)
      end
      job.acknowledge!
      result
    end

    def perform(job)
      logger.debug "RUNNING"
      job.perform
      logger.debug "COMPLETED"
      return true # did work
    rescue StandardError => error
      logger.error "FAILED with #{error}"
      return false # work FAILED
    end
  end
end
