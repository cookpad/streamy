require "hutch"

module Streamy
  module MessageBuses
    class RabbitMessageBus < MessageBus
      def initialize(uri:, routing_key_prefix: "global")
        Hutch::Config.set(:uri, uri)
        Hutch::Config.set(:enable_http_api_use, false)
        @routing_key_prefix = routing_key_prefix
      end

      def deliver(key:, topic:, type:, body:, event_time:)
        Message.new(
          key: key,
          topic: topic,
          type: type,
          body: body,
          event_time: event_time,
          routing_key_prefix: routing_key_prefix
        ).publish
      end

      private

        attr_reader :routing_key_prefix

    end
  end
end
