module Streamy
  module MessageBuses
    class TestMessageBus < MessageBus
      cattr_accessor :deliveries do
        []
      end

      def deliver(params = {})
        deliveries << params
      end

      def bulk_deliver
        yield
      end
    end
  end
end
