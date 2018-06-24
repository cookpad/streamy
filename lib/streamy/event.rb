module Streamy
  class Event
    def self.publish(*args)
      new(*args).publish
    end

    def publish
      message_bus.safe_deliver(
        key: key,
        topic: topic,
        type: type,
        body: body,
        event_time: event_time,
        priority: priority
      )
    end

    private

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

      def priority
        :standard
      end
  end
end
