require "hutch"

module Streamy
  module Consumer
    def self.included(base)
      base.include Hutch::Consumer
      base.extend ClassMethods
    end

    module ClassMethods
      def pause_consumer!
        Hutch.consumers.delete self

        Hutch::Config.setup_procs << Proc.new do
          Hutch.logger.info("setting up paused queue: #{get_queue_name}")
          queue = Hutch.broker.queue(get_queue_name, get_arguments)
          Hutch.broker.bind_queue(queue, routing_keys)
        end
      end
    end

    def process(message)
      MessageProcessor.new(message).run
    end
  end
end
