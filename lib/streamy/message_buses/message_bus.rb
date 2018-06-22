module Streamy
  module MessageBuses
    class MessageBus
      def safe_deliver(*args)
        deliver(*args)
      rescue => e
        raise PublicationFailedError.new(e, *args)
      end

      def deliver(key:, topic:, type:, body:, event_time:,priority:)
        raise "not implemented"
      end
    end
  end
end
