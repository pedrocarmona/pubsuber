# frozen_string_literal: true

namespace :jobs do
  desc "Start a PubSuber worker, rake 'jobs:work'"
  task :work do
    require "pub_suber"
    queues = (ENV["QUEUES"] || ENV["QUEUE"] || "").split(",")
    worker = PubSuber::Worker.new(queues: queues)
    worker.start
  end

  desc "Enqueues a job in queues, rake 'jobs:enqueue'"
  task :enqueue, [:job] do |_t, args|
    require "pub_suber"
    queues = (ENV["QUEUES"] || ENV["QUEUE"] || "").split(",")
    driver = PubSuber::Driver.new
    queues.each do |queue|
      job = PubSuber::Job.build(
        queue: queue,
        job_class: PubSuber::BashJob,
        command: "ls"
      )
      driver.enqueue(message: job.to_h, topic: job["queue"])
    end
  end
end
