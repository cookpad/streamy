module Streamy
  module MessageBuses
    class MessageBus
      def deliver(key:, topic:, payload:, priority:)
        # NOOP: Implement delivery logic
      end

      def deliver_many(messages)
        # NOOP: Implement delivery logic
      end
    end
  end
end
