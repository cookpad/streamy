require "streamy/helpers/have_hash_matcher"
require "streamy/test_dispatcher"

module Streamy
  module Helpers
    module RspecHelper
      def expect_event(topic: kind_of(String), priority: kind_of(Symbol), key: kind_of(String), body: kind_of(Hash), type:, event_time: nil)
        expect(streamy_deliveries).to have_hash(
          priority: priority,
          topic: topic,
          key: key,
          payload: {
            body: body,
            type: type,
            event_time: event_time || kind_of(Time)
          }
        )
      end

      def expect_no_event(type:)
        expect(streamy_deliveries).not_to have_hash(payload: a_hash_including(type: type.to_s))
      end

      def expect_events
        expect(streamy_deliveries).not_to be_empty
      end

      def streamy_deliveries
        TestDispatcher.events
      end

      Streamy.dispatcher = TestDispatcher

      RSpec.configure do |config|
        config.include Streamy::Helpers::RspecHelper

        config.before(:each) do
          TestDispatcher.events.clear
        end
      end
    end
  end
end
