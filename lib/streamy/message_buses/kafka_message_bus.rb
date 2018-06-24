require "kafka"

module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      def initialize(config)
        @async_config = config.slice(*async_config.keys)
        @producer_config = config.slice(*producer_config.keys)
        @kafka = Kafka.new(config.except(*(async_config.keys + producer_config.keys)))
      end

      def deliver(key:, topic:, type:, body:, event_time:, priority:)
        payload = {
          type: type,
          body: body,
          event_time: event_time
        }.to_json

        producer(priority).produce(payload, key: key, topic: topic)
        producer(priority).deliver_messages unless %i(low manual).include? priority
      end

      def deliver_events
        async_producer.deliver_messages if async_producer?
        sync_producers.map(&:deliver_messages)
      end

      def shutdown
        async_producer.shutdown if async_producer?
        sync_producers.map(&:shutdown)
      end

      private

        attr_reader :kafka

        def producer(priority)
          case priority
          when :essential, :manual
            return sync_producer
          when :standard, :low
            async_producer
          else
            fail "Unknown priority"
          end
        end

        def async_producer
          @producer ||= kafka.async_producer(**async_config, **producer_config)
        end

        def async_producer?
          !@producer.nil?
        end

        def sync_producer
          # One synchronous producer per-thread to avoid problems with concurrent deliveries.
          Thread.current[:streamy_kafka_sync_producer] ||= kafka.producer(**producer_config)
        end

        def sync_producers
          Thread.list.map do |thread|
            thread[:streamy_kafka_sync_producer]
          end.compact
        end

        def async_config
          {
            max_queue_size:      1000,
            delivery_threshold:  25,
            delivery_interval:   5
          }.merge(@async_config || {})
        end

        def producer_config
          {
            required_acks:       -1, # all replicas
            ack_timeout:         5,
            max_retries:         30,
            retry_backoff:       2,
            max_buffer_size:     1000,
            max_buffer_bytesize: 10_000_000
          }.merge(@producer_config || {})
        end
    end
  end
end
