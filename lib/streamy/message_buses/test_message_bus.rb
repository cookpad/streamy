module Streamy
  module MessageBuses
    class TestMessageBus < MessageBus
      cattr_accessor :deliveries do
        []
      end

      def deliver(params = {})
        deliveries << params
      end

      def sync_producer_deliver_messages; end
    end
  end
end
