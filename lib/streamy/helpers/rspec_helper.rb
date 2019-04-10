require "streamy/helpers/have_hash_matcher"
require "streamy/helpers/message_parser"

module Streamy
  module Helpers
    module RspecHelper
      include Streamy::Helpers::MessageParser

      def expect_event(topic: kind_of(String), key: kind_of(String), body: kind_of(Hash), type:, event_time: kind_of(String), encoding: "json")
        deliveries = hashify_messages(Streamy.message_bus.deliveries, encoding)

        expect(deliveries).to have_hash(
          topic: topic,
          key: key,
          payload: {
            body: body,
            type: type,
            event_time: event_time
          }
        )
      end

      def expect_avro_event(**options)
        expect_event(**options, encoding: "avro")
      end

      alias expect_published_event expect_event
      alias expect_published_avro_event expect_avro_event

      Streamy.message_bus = MessageBuses::TestMessageBus.new

      RSpec.configure do |config|
        config.include Streamy::Helpers::RspecHelper

        config.before(:each) do
          Streamy.message_bus.deliveries.clear
        end
      end
    end
  end
end
