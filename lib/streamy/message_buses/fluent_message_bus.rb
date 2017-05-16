module Streamy
  module MessageBuses
    class FluentMessageBus
      TAG = "domain_events"

      def initialize(tag_prefix)
        @tag_prefix = tag_prefix
      end

      def deliver(key:, topic:, type:, body:, event_time:)
        client.post TAG,
          key: key,
          topic: topic,
          type: type,
          body: body,
          event_time: event_time
      end

      private

        attr_reader :tag_prefix

        def client
          @client ||= Fluent::Logger::FluentLogger.new(tag_prefix)
        end
    end
  end
end
