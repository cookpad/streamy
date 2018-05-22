require "kafka"

module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      def initialize(seed_brokers: ["127.0.0.1:9092"], client_id: :default_app_name)
        @kafka ||= Kafka.new(seed_brokers, client_id: client_id.to_s)
      end

      def deliver(key:, topic:, type:, body:, event_time:)
        payload = {
          key: key,
          type: type,
          body: body,
          event_time: event_time
        }
        kafka.deliver_message(payload, topic: topic)
      end

      private

        attr_reader :kafka
    end
  end
end
