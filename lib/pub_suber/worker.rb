# frozen_string_literal: true

module PubSuber
  # TODO: should control the lifecycle (processing, failed,
  # failed_and_rescheduled, successful)
  # TODO: should save metrics, kind of job, status,
  class Worker
    attr_accessor :max_attempts, :sleep_delay, :queues, :name, :logger

    def self.build(options = {})
      options[:sleep_delay] =
        options.fetch(:sleep_delay, Settings.sleep_delay)
      options[:max_attempts] =
        options.fetch(:max_attempts, Settings.max_attempts)
      options[:failed_jobs_queue_name] =
        options.fetch(:failed_jobs_queue_name, Settings.failed_jobs_queue_name)
      options[:queues] = options.fetch(:queues)
      new(options)
    end

    def initialize(options = {})
      @sleep_delay = options[:sleep_delay]
      @max_attempts = options[:max_attempts]
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
      job = reserve_job
      invoke_job if job
    end

    def invoke_job
      logger.debug "RUNNING"
      job.invoke_job
      logger.debug "COMPLETED"
      job.acknowledge
      return true # did work
    rescue StandardError => error
      logger.error "FAILED with #{error}"
      job.acknowledge
      handle_failed_job(job, error)
      return false # work failed
    end

    def handle_failed_job(job)
      if can_reschedule?
        reschedule(job)
      else
        failed(job)
      end
    end

    def can_reschedule?
      job.attempts += 1
      job.attempts < max_job_attempts(job)
    end

    def max_job_attempts(job)
      job.max_attempts || max_attempts
    end

    # Reschedule the job in the future (when a job fails).
    def reschedule(job)
      @driver.enqueue(message: job, topic: job.queue_name)
    end

    # send to failed queue
    def failed(job)
      logger.debug "failed moved to #{failed_jobs_queue_name}"
      @driver.enqueue(message: job, topic: failed_jobs_queue_name)
    end

    # Goes through the queues and reserves only one job
    # If there is one jobs in first queue, then returns it
    # If there are no jobs in the queue, proceeds to the next queue
    # The order of queues specifies the priority
    def reserve_job
      queues.lazy.select { |queue| @driver.reserve(topic: queue) }.first
    end
  end
end
