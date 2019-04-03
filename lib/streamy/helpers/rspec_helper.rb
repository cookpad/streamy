require "streamy/helpers/have_hash_matcher"

module Streamy
  module Helpers
    module RspecHelper
      def expect_event(topic: kind_of(String), key: kind_of(String), body: kind_of(Hash), type:, event_time: nil)
        deliveries = normalize_deliveries(Streamy.message_bus.deliveries)

        expect(deliveries).to have_hash(
          topic: topic,
          key: key,
          payload: {
            body: body,
            type: type,
            event_time: event_time || kind_of(Time)
          }
        )
      end

      def normalize_deliveries(message_bus_deliveries)
        message_bus_deliveries.each do |message|
          message[:payload] = JSON.parse(message[:payload]).deep_symbolize_keys
          message
        end
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
