module Streamy
  module MessageBuses
    class TestMessageBus < MessageBus
      attr_accessor :deliveries
      attr_reader :buffer_size

      def initialize(config: { max_buffer_size: 10 })
        @config = config
        @deliveries = []
        @batched = []
        @buffer_size = 0
      end

      def deliver(params = {})
        if params[:priority] == :batched
          batched_deliver(params)
        else
          @deliveries << params
        end
      end

      def syncronized_deliver_messages
        @deliveries += batched
        @batched = []
        deliveries
      end

      private

        attr_reader :config, :batched

        def batched_deliver(params = {})
          @batched << params
          @buffer_size += 1
          deliver_messages if buffer_full?
        end

        def buffer_full?
          config[:max_buffer_size] == buffer_size
        end

        def max_buffer_size
          config[:max_buffer_size]
        end
    end
  end
end
