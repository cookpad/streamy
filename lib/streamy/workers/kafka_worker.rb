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
          klass = klass_name(topic).constantize
          klass.new(kafka: kafka, topic: topic)
        end

        def klass_name(topic)
          consumer_name = topic.split(".").last + "_consumer"
          consumer_name.camelize
        end
    end
  end
end
