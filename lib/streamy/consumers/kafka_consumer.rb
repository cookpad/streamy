module Streamy
  module Consumers
    class KafkaConsumer
      def initialize(kafka:, topic:)
        @kafka = kafka
        @topic = topic
      end

      delegate :subscribe, :each_message, :stop, to: :kafka_consumer

      def shutdown
        puts "Shutting down..."
        stop
      end

      def process(kafka_message)
        json = JSON.parse(kafka_message.value).deep_symbolize_keys

        message = {
          key: kafka_message.key,
          body: json,
          type: json[:type],
          event_time: json[:event_time]
        }

        MessageProcessor.new(message).run
      end

      private

        attr_reader :topic, :kafka

        def kafka_consumer
          @_kafka_consumer ||= kafka.consumer(group_id: consumer_group_name)
        end

        def consumer_group_name
          "#{topic}_consumer"
        end
    end
  end
end
