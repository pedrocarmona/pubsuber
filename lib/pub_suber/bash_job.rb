# frozen_string_literal: true

module PubSuber
  # BashJob - runs a command in worker's host bash
  # for now, will insert this as part of the gem, but shouldnt.
  # I need to start a new web project inside this integration folder
  # which will have the BashJob
  class BashJob
    def initialize(job)
      @command = job["args"]["command"]
    end

    def perform
      `#{@command}`
    end
  end
end
