# frozen_string_literal: true

module PubSuber
  class Driver
    def initialize
      gcloud = Google::Cloud.new(Settings.project_id)
      @pubsub = gcloud.pubsub
      @message_deadline = Settings.message_deadline
    end

    def enqueue(message:, topic:) #:nodoc:
      topic = @pubsub.topic(topic, autocreate: true)
      topic.publish(message)
    end

    def enqueue_at(_message:, _topic:, _timestamp:) #:nodoc:
      # TODO: implement a schedule inbox topic,
      # that pushes the message to the right topic
      # after a given timestamp
      fail NotImplementedError, "PubSub doesnt allow it"
    end

    # Goes through the queues and reserves only one job
    # If there is one jobs in first queue, then returns it
    # If there are no jobs in the queue, proceeds to the next queue
    # The order of queues specifies the priority
    def reserve_one_job(queues)
      job = nil
      queues.find do |queue|
        logger.info "Trying to reserve job in queue #{queue}"
        reserved_message = reserve(topic: queue)
        job = reserved_message.job if reserved_message
        break if job
      end
      job
    end

    # Publish in a queue the successful job.
    def successful(job)
      logger.info "Publish successful #{job}"
      enqueue(message: job, topic: Settings.sucessful_jobs_queue_name )
    end

    # Reschedule the job in the future (when a job fails).
    def reschedule(job)
      logger.info "Publish rescheduled #{job}"
      enqueue(message: job, topic: job.queue_name)
    end

    # send to buried queue
    def bury(job)
      logger.info "Publish buried #{job}"
      enqueue(message: job, topic: Settings.buried_jobs_queue_name )
    end

    private

    def subscription(topic_name, message_deadline)
      topic = @pubsub.topic(topic_name, autocreate: true)
      subscription = topic.subscription(topic_name)
      return subscription if subscription && subscription.exists?
      topic.subscribe(topic_name, deadline: message_deadline)
      topic.subscription(topic_name)
    end

    def reserve(topic:, message_deadline: @message_deadline)
      subscription = subscription(topic, message_deadline)
      message = subscription.pull(max: 1).first
      ReservedMessage.new(message, message_deadline) if message
    end
  end
end
