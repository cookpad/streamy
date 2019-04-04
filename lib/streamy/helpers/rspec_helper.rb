require "streamy/helpers/have_hash_matcher"

module Streamy
  module Helpers
    module RspecHelper
      def expect_event(topic: kind_of(String), key: kind_of(String), body: kind_of(Hash), type:, event_time: kind_of(String))
        deliveries = hashify_messages(Streamy.message_bus.deliveries)

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

      def hashify_messages(message_bus_deliveries)
        message_bus_deliveries.map do |message|
          message_hash = message.dup
          message_hash[:payload] = JSON.parse(message_hash[:payload]).deep_symbolize_keys
          message_hash
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
