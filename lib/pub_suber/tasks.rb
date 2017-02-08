# frozen_string_literal: true

namespace :jobs do
  desc "Start a PubSuber worker, rake 'jobs:work'"
  task :work do
    require "pub_suber"
    queues = (ENV["QUEUES"] || ENV["QUEUE"] || "").split(",")
    worker = PubSuber::Worker.build(queues: queues)
    worker.start
  end

  desc "Enqueues a job in queues, rake 'jobs:enqueue[\"my job\"]'"
  task :enqueue, [:job] do |_t, args|
    require "pub_suber"
    queues = (ENV["QUEUES"] || ENV["QUEUE"] || "").split(",")
    driver = PubSuber::Driver.new
    queues.each do |queue|
      driver.enqueue(message: args[:job], topic: queue)
    end
  end
end
