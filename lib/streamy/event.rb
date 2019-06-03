require "active_support/core_ext/class/attribute"
require "streamy/dispatcher"

module Streamy
  class Event
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
      Streamy.dispatcher.new(self).dispatch
    end

    def to_message
      to_params.merge(payload: encoded_payload)
    end

    def to_params
      {
        key: key,
        topic: topic,
        priority: priority,
        payload: payload
      }
    end

    private

      def priority
        default_priority
      end

      def encoded_payload
        payload
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

      def payload
        {
          type: type,
          body: body,
          event_time: event_time
        }
      end
  end
end
