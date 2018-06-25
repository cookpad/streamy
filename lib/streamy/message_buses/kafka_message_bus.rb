require "kafka"

module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      def initialize(config)
        @config = config
        @kafka = Kafka.new(kafka_config)
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

        attr_reader :kafka, :config

        DEFAULT_PRODUCER_CONFIG = {
          required_acks:       -1, # all replicas
          ack_timeout:         5,
          max_retries:         30,
          retry_backoff:       2,
          max_buffer_size:     1000,
          max_buffer_bytesize: 10_000_000
        }.freeze

        DEFAULT_ASYNC_CONFIG = {
          max_queue_size:      1000,
          delivery_threshold:  25,
          delivery_interval:   5
        }.freeze

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
          @_async_producer ||= kafka.async_producer(**async_config)
        end

        def async_producer?
          @_async_producer.present?
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
          config.slice(*DEFAULT_ASYNC_CONFIG.keys).with_defaults(DEFAULT_ASYNC_CONFIG).merge(producer_config)
        end

        def producer_config
          config.slice(*DEFAULT_PRODUCER_CONFIG.keys).with_defaults(DEFAULT_PRODUCER_CONFIG)
        end

        def kafka_config
          config.except(*async_config.keys)
        end
    end
  end
end
