module Streamy
  module Workers
    class KafkaWorker
      def initialize(config)
        @kafka = Kafka.new(config)
      end

      def run(topic)
        raise "Topic must be specified" unless topic
        topic_consumer = consumer(topic)

        # Stop the consumer when the SIGTERM signal is sent to the process.
        trap("TERM") { topic_consumer.shutdown }
        trap("INT") { topic_consumer.shutdown }

        topic_consumer.subscribe(topic)
        topic_consumer.each_message { |message| topic_consumer.process(message) }
      end

      private

        attr_reader :kafka

        def consumer(topic)
          Consumers::KafkaConsumer.new(kafka: kafka, topic: topic)
        end
    end
  end
end
