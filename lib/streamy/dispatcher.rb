module Streamy
  class Dispatcher
    def initialize(event)
      @event = event
    end

    def dispatch
      Streamy.message_bus.deliver(**message_params)
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
