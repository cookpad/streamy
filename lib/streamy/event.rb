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
        event_time: event_time
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
        raise "topic not implemented on event"
      end

      def body
        raise "body not implemented on event"
      end

      def event_time
        raise "event_time not implemented on event"
      end
  end
end
