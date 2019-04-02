require "streamy/helpers/have_hash_matcher"

module Streamy
  module Helpers
    module RspecHelper
      def expect_event(topic: kind_of(String), key: kind_of(String), body: nil, type: nil, event_time: nil)
        expect(Streamy.message_bus.deliveries).to have_hash(
          topic: topic,
          key: key
        )
        assert_payload_match(body, type, event_time)
      end

      def assert_payload_match(body, type, event_time)
        payload_hash = JSON.parse(Streamy.message_bus.deliveries.first[:payload])
        assert_body_match(body, payload_hash) if body
        assert_type_match(type, payload_hash) if type
        assert_event_time_match(event_time, payload_hash) if event_time
      end

      def assert_body_match(body, payload_hash)
        expect(body.stringify_keys).to eq(payload_hash["body"])
      end

      def assert_type_match(type, payload_hash)
        expect(type).to eq(payload_hash["type"])
      end

      def assert_event_time_match(event_time, payload_hash)
        expect(event_time).to eq(payload_hash["event_time"])
      end
      alias expect_published_event expect_event

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
