module Streamy
  module MessageBuses
    class TestMessageBus
      cattr_accessor :deliveries do
        []
      end

      def deliver(params = {})
        self.deliveries << params
      end
    end
  end
end
