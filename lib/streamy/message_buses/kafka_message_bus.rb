require "streamy/kafka_configuration"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/json"

module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      def initialize(config)
        @config = KafkaConfiguration.new(config)
      end

      def deliver(key:, topic:, payload:, priority:)
        producer(priority).tap do |p|
          case priority
          when :essential
            sync_producer.produce_sync(payload: payload, key: key, topic: "#{topic}")
          when :standard, :low
            async_producer.produce_async(payload: payload, key: key, topic: "#{topic}")
          else
            fail "Unknown priority"
          end
        end
      end

      def shutdown
        async_producer.shutdown if async_producer?
        sync_producers.map(&:shutdown)
      end

      private

        attr_reader :producer, :config

        def producer(priority)
          case priority
          when :essential
            return sync_producer
          when :standard, :low
            async_producer
          else
            fail "Unknown priority"
          end
        end

        def async_producer
          @async_producer = WaterDrop::Producer.new do |producer_config|
            # to be **config.async
            producer_config.kafka = { 'bootstrap.servers': 'localhost:9092' }
          end
        end

        def async_producer?
          @_async_producer.present?
        end

        def sync_producer
          # One synchronous producer per-thread to avoid problems with concurrent deliveries.
          Thread.current[:streamy_kafka_sync_producer] ||= build_sync_producer
        end

        def build_sync_producer
          WaterDrop::Producer.new do |producer_config|
            # to be **config.producer
            producer_config.kafka = { 'bootstrap.servers': 'localhost:9092' }
          end
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
