# frozen_string_literal: true

module PubSuber
  class ReservedMessage
    def initialize(message, message_deadline)
      @logger = Settings.logger
      @logger.info("ReservedMessage: #{message}")
      @message = message
      @message_deadline = message_deadline
      @background = background_extend_deadline
    end

    def background_extend_deadline
      renew_deadline_interval = @message_deadline * 0.80 # default: 480s
      Thread.new do
        loop {
          sleep renew_deadline_interval
          @logger.info("Extended message deadline: #{@message.attributes}")
          @message.delay!(@message_deadline)
        }
      end
    end

    def acknowledge!
      @background.exit
      @message.acknowledge!
      @logger.info("ACKED #{@message.attributes}.")
    end
  end
end
