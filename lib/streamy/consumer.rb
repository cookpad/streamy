require "hutch"

module Streamy
  module Consumer
    def self.included(base)
      base.include Hutch::Consumer
      base.extend ClassMethods
    end

    module ClassMethods
      def replay(routing_key)
        # Set up keys / queues
        replay_routing_key_prefix = "replay.#{get_queue_name}"
        replay_routing_key = "#{replay_routing_key_prefix}.#{routing_key}"
        paused_queue = get_queue_name
        replay_queue = "#{paused_queue}_replay"

        # Configure hutch
        consume replay_routing_key
        queue_name replay_queue

        # Manually create "paused queue"
        Hutch::Config.setup_procs << Proc.new do
          Hutch.logger.info("setting up paused queue: #{paused_queue}")
          queue = Hutch.broker.queue(paused_queue, get_arguments)
          Hutch.broker.bind_queue(queue, [routing_key])
        end
      end
    end

    def process(message)
      MessageProcessor.new(message).run
    end
  end
end
