module Streamy
  class Dispatcher
    def initialize(event)
      @event = event
    end

    def dispatch
      Streamy.message_bus.deliver(**message_params)
    end

    def self.dispatch_many(events)
      Streamy.message_bus.deliver_many(events.map(&:to_message))
    end

    private

      attr_reader :event

      def message_params
        event.to_message
      end

      def event_params
        event.to_params
      end
  end
end
