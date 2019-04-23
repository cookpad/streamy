module Streamy
  module MessageBuses
    class MessageBus
      def safe_deliver(*args)
        deliver(*args)
      rescue StandardError => e
        raise PublicationFailedError.new(e, *args)
      end

      def deliver(key:, topic:, payload:, priority:)
        raise "not implemented"
      end

      def bulk_deliver
        raise "not implemented"
      end
    end
  end
end
