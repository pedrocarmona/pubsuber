# frozen_string_literal: true

module PubSuber
  class ReservedMessage
    def initialize(subscription, message_deadline)
      @message = subscription.pull(max: 1).first
      @message_deadline = message_deadline
      @background = background_extend_deadline
    end

    def background_extend_deadline
      renew_deadline_interval = @message_deadline * 0.80 # default: 480s
      Thread.new do
        loop {
          sleep renew_deadline_interval
          Log.info("Extended message deadline: #{@message.attributes}")
          @message.delay!(@message_deadline)
        }
      end
    end

    def acknowledge!
      @background.exit
      @message.acknowledge!
      Log.info("ACKED #{@message.attributes}.")
    end
  end
end
