require "active_support/core_ext/class/attribute"
require "avro_turf/messaging"

module Streamy
  class AvroEvent
    ALLOWED_PRIORITIES = %I[low standard essential batched].freeze
    class_attribute :default_priority

    def self.priority(level)
      raise "unknown priority: #{level}" unless ALLOWED_PRIORITIES.include? level
      self.default_priority = level
    end

    def self.publish(*args)
      new(*args).publish
    end

    priority :standard

    def publish
      message_bus.safe_deliver(
        payload: payload,
        key: key,
        topic: topic,
        priority: priority
      )
    end

    private

      def payload
        avro.encode(attributes.stringify_keys, schema_name: type)
      end

      def attributes
        {
          type: type,
          body: body.stringify_keys,
          event_time: event_time
        }
      end

      def priority
        default_priority
      end

      def message_bus
        Streamy.message_bus
      end

      def key
        @_key ||= SecureRandom.uuid
      end

      def type
        self.class.name.demodulize.underscore
      end

      def topic
        raise "topic must be implemented on #{self.class}"
      end

      def body
        raise "body must be implemented on #{self.class}"
      end

      def event_time
        raise "event_time must be implemented on #{self.class}"
      end

      def avro
        AvroTurf::Messaging.new(registry_url: ENV["SCHEMA_REGISTRY_URLs"])
      end
  end
end
