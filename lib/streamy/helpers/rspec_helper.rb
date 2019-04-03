require "streamy/helpers/have_hash_matcher"

module Streamy
  module Helpers
    module RspecHelper
      def expect_event(topic: kind_of(String), key: kind_of(String), body: nil, type:, event_time: nil)
        expect(Streamy.message_bus.deliveries).to have_hash(
          topic: topic,
          key: key
        )

        payload_hash = JSON.parse(Streamy.message_bus.deliveries.last[:payload]).deep_symbolize_keys
        expect(payload_hash[:body]).to match(body) if body
        expect(type).to eq(payload_hash[:type])
        expect(event_time).to eq(payload_hash[:event_time]) if event_time
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
