require "streamy/helpers/have_hash_matcher"

module Streamy
  module Helpers
    module RspecHelper
      def expect_published_event(topic: kind_of(String), type:, body:, event_time: nil)
        expect(Streamy.message_bus.deliveries).to have_hash(
          topic: topic,
          type: type,
          body: body,
          event_time: event_time || kind_of(Time)
        )
      end

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
