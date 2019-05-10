module Streamy
  module MessageBuses
    class MessageBus
      def deliver(key:, topic:, payload:, priority:)
        # NOOP: Implement delivery logic
      end

      def sync_producer_deliver_messages
        # TODO: Shouldn't live here, is a kafka-specific feature
      end
    end
  end
end
