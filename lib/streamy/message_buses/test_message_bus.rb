module Streamy
  module MessageBuses
    class TestMessageBus < MessageBus
      cattr_accessor :deliveries do
        []
      end

      def deliver(params = {})
        params[:serializer].encode(params[:payload])

        deliveries << params
      end

      def sync_producer_deliver_messages; end
    end
  end
end
