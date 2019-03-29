require "streamy/kafka_configuration"
require "kafka"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/json"

module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      def initialize(config)
        @config = KafkaConfiguration.new(config)
        @kafka = Kafka.new(@config.kafka)
      end

      def deliver(key:, topic:, type:, body:, event_time:, priority:)
        payload = {
          type: type,
          body: body,
          event_time: event_time
        }.to_json

        producer(priority).tap do |p|
          p.produce(payload, key: key, topic: topic)
          case priority
          when :essential, :standard
            p.deliver_messages
          when :batched
            if config.producer[:max_buffer_size] == p.buffer_size
              logger.info "Delivering #{p.buffer_size} batched events now"
              p.deliver_messages
            end
          end
        end
      end

      def shutdown
        async_producer.shutdown if async_producer?
        sync_producers.map(&:shutdown)
      end

      private

        attr_reader :kafka, :config

        def producer(priority)
          case priority
          when :essential, :batched
            return sync_producer
          when :standard, :low
            async_producer
          else
            fail "Unknown priority"
          end
        end

        def async_producer
          @_async_producer ||= kafka.async_producer(**config.async)
        end

        def async_producer?
          @_async_producer.present?
        end

        def sync_producer
          # One synchronous producer per-thread to avoid problems with concurrent deliveries.
          Thread.current[:streamy_kafka_sync_producer] ||= kafka.producer(**config.producer)
        end

        def sync_producers
          Thread.list.map do |thread|
            thread[:streamy_kafka_sync_producer]
          end.compact
        end

        def logger
          ::Streamy.logger
        end
    end
  end
end
