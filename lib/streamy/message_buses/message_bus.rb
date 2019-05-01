module Streamy
  module MessageBuses
    class MessageBus
      def safe_deliver(*args)
        deliver(*args)
      rescue StandardError => e
        raise PublicationFailedError.new(e, *args)
      end

      def deliver(key:, topic:, payload:, priority:, serializer:)
        raise "not implemented"
      end
    end
  end
end
