# require "kafka"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/json"

module Streamy
  module MessageBuses
    class KafkaMessageBus < MessageBus
      # delegate :deliver_messages, to: :sync_producer, prefix: true

      def initialize
        # @config = KafkaConfiguration.new(config)
        # @kafka = ::KarafkaApp.new(**@config.kafka)
        @kafka = Karafka

        # @kafka.setup do |config|
        #   config.kafka = { 'bootstrap.servers': 'localhost:9092' }
        # end
      end

      def deliver(key:, topic:, payload:, priority:)
        producer(priority).tap do |p|
          case priority
          when :essential
            Karafka.producer.produce_sync(payload: payload, key: key, topic: "#{topic}")
          when :standard, :low
            Karafka.producer.produce_async(payload: payload, key: key, topic: "#{topic}")
          else
            fail "Unknown priority"
          end

          # p.produce(payload, key: key, topic: topic)
          # case priority
          # when :essential, :standard
          #   p.deliver_messages
          # when :batched
          #   if p.buffer_size >= batched_message_limit
          #     logger.info "Delivering #{p.buffer_size} batched events now"
          #     p.deliver_messages
          #   end
          # end
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

        def producer(priority)
          case priority
          when :essential, :batched
            return Karafka.producer
          when :standard, :low
            Karafka.producer
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
          Thread.current[:streamy_kafka_sync_producer] ||= build_sync_producer
        end

        def build_sync_producer
          kafka.producer.tap do |producer|
            producer.setup { |config| config.kafka = config }
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

        def batched_message_limit
          config.producer[:max_buffer_size] - 1
        end
    end
  end
end
