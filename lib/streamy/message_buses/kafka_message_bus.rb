module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      def initialize(kafka:)
        @kafka = kafka
      end

      def deliver(key:, topic:, type:, body:, event_time:)
        payload = {
          type: type,
          body: body,
          event_time: event_time
        }
        kafka.deliver_message(payload, key: key, topic: topic)
      end

      private

        attr_reader :kafka
    end
  end
end
