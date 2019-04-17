module Streamy
  module MessageBuses
    class TestMessageBus < MessageBus
      attr_accessor :deliveries

      def initialize(config: { max_buffer_size: 10 })
        @config = config
        @deliveries = []
        @batched = []
        @buffer_size = 0
      end

      def deliver(params = {})
        if params[:priority] == :batched
          batch_messages [params]
          sync_producer_deliver_messages if buffer_full?
        else
          deliver_messages [params]
        end
      end

      def sync_producer_deliver_messages
        deliver_messages batched
        flush_batch
      end

      private

        attr_reader :config, :buffer_size, :batched

        def deliver_messages(event)
          @deliveries += event
        end

        def batch_messages(event)
          increase_buffer
          @batched += event
        end

        def increase_buffer
          @buffer_size += 1
        end

        def flush_batch
          @buffer_size = 0
          @batched = []
        end

        def buffer_full?
          max_buffer_size == buffer_size
        end

        def max_buffer_size
          config[:max_buffer_size]
        end
    end
  end
end
