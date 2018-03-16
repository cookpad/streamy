require "hutch"

module Streamy
  module MessageBuses
    class RabbitMessageBus
      def initialize(uri:)
        Hutch::Config.set(:uri, uri)
        Hutch::Config.set(:enable_http_api_use, false)
      end

      def deliver(*args)
        deliver_now(*args)
      end

      def deliver_now(key:, topic:, type:, body:, event_time:)
        Message.new(
          key: key,
          topic: topic,
          type: type,
          body: body,
          event_time: event_time
        ).publish
      end
    end
  end
end
