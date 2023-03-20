require "streamy/kafka_configuration"
require "waterdrop"
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
            p.produce_sync(payload: payload, key: key, topic: topic.to_s)
          when :standard, :low
            p.produce_async(payload: payload, key: key, topic: topic.to_s)
          else
            raise ::Streamy::UnknownPriorityError.new(priority)
          end
        end
      end

      def shutdown
        async_producer.shutdown if async_producer?
        sync_producers.map(&:shutdown)
      end

      private

        attr_reader :config

        def producer(priority)
          case priority
          when :essential
            sync_producer
          when :standard, :low
            async_producer
          else
            raise UnknownPriorityError.new(priority)
          end
        end

        def async_producer
          @_async_producer ||= build_async_producer
        end

        def async_producer?
          @_async_producer.present?
        end

        def sync_producer
          # One synchronous producer per-thread to avoid problems with concurrent deliveries.
          Thread.current[:streamy_kafka_sync_producer] ||= build_sync_producer
        end

        def build_sync_producer
          build_producer(kafka_config_for(:sync))
        end

        def build_async_producer
          build_producer(kafka_config_for(:async))
        end

        def build_producer(kafka_config)
          WaterDrop::Producer.new do |producer_config|
            producer_config.logger = logger
            producer_config.monitor = WaterDrop::Instrumentation::Monitor.new(
              Streamy.notifications_bus,
              Streamy.notifications_bus_namespace
            )
            producer_config.kafka = kafka_config
          end
        end

        def kafka_config_for(producer_type)
          case producer_type
          when :sync
            config.sync
          when :async
            config.async
          else
            raise UnknownProducerTypeError.new(producer_type)
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
