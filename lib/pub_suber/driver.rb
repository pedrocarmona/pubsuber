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

    def reserve(topic:, message_deadline: @message_deadline)
      subscription = subscription(topic, message_deadline)
      ReservedMessage.new(subscription, message_deadline)
    end

    private

    def subscription(topic_name, message_deadline)
      topic = @pubsub.topic(topic_name, autocreate: true)
      subscription = topic.subscription(topic)
      return subscription if subscription.exists?
      topic.subscribe(topic_name, message_deadline: message_deadline)
      topic.subscription(topic)
    end
  end
end
