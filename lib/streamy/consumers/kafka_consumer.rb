module Streamy
  module Consumers
    class KafkaConsumer
      def initialize(kafka:, topic:)
        @kafka = kafka
        @topic = topic
      end

      delegate :subscribe, :each_message, :stop, to: :kafka_consumer

      def process(kafka_message)
        json = JSON.parse(kafka_message.value).deep_symbolize_keys

        MessageProcessor.new(message(json, kafka_message)).run
      end

      def shutdown
        puts "Shutting down..."
        stop
      end

      private

        attr_reader :topic, :kafka

        def kafka_consumer
          @_kafka_consumer ||= kafka.consumer(group_id: "#{topic}_consumer")
        end

        def message(json, kafka_message)
          {
            key: kafka_message.key,
            body: json,
            type: json[:type],
            event_time: json[:event_time]
          }
        end
    end
  end
end
