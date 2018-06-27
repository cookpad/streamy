require "hutch"

module Streamy
  module MessageBuses
    class RabbitMessageBus < MessageBus
      class Message
        def initialize(routing_key_prefix: nil, **params)
          @routing_key_prefix = routing_key_prefix
          @params = params
        end

        def publish
          Hutch.connect
          Hutch.publish(routing_key, params)
        end

        private

          attr_reader :params, :routing_key_prefix

          def routing_key
            [routing_key_prefix, topic, type].compact.join(".")
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
end
