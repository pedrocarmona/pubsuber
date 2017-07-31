# frozen_string_literal: true

module PubSuber
  class Job
    attr_reader :item, :reserved_message

    # used by scheduler 
    def initialize(item, reserved_message)
      @reserved_message = reserved_message
      @item = item.is_a?(Hash) ? item : parse(item)
    end

    # used by scheduler 
    def self.build(queue:, job_class:, **args)
      item = Hash.new
      item["queue"] = queue
      item["class"] = job_class
      item["job_id"] = SecureRandom.uuid
      item["created_at"] = Time.now.utc
      item["max_attempts"] = Settings.max_attempts
      item["attempts"] = 0
      item["args"] = args
      new(item, nil)
    end

    def perform
      implementation_class = find_class!(@item["class"])
      implementation = klass.new(@item)
      register_attempt
      implementation.perform
    end

    def acknowledge!
      @reserved_message.acknowledge!
    end

    def can_reschedule?
      @item["attempts"] < @item["max_attempts"]
    end

    def register_attempt
      @item["attempts"] = @item["attempts"] + 1
    end

    def queue
      @item["queue"]
    end

    def [](name)
      @item[name]
    end

    def parse(string)
      JSON.parse(string)
    end
  
    def serialize
      JSON.generate(@item)
    end

    def to_h
      array = @item.flat_map { |key, value| [key.to_sym, value] }
      Hash[*array]
    end

    private

    def find_class!(class_name)
      fail(NotFoundError.new(self, name)) unless Object.const_defined?(class_name)
      Object.const_get(class_name)
    end
  end
end