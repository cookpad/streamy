require "hutch"

module Streamy
  module MessageBuses
    class RabbitMessageBus::Message
      def initialize(**params)
        @params = params
      end

      def publish
        Hutch.connect
        Hutch.publish(routing_key, params)
      end

      private

        attr_reader :params

        def routing_key
          "#{Streamy.routing_prefix}.#{topic}.#{type}"
        end

        def topic
          params[:topic]
        end

        def type
          params[:type]
        end
    end
  end
end
