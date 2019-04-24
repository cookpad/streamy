require "streamy/helpers/message_parser"
require "webmock/minitest"

module Streamy
  module AssertEvent
    include Streamy::Helpers::MessageParser

    def assert_event(attributes = {})
      deliveries = hashify_messages(Streamy.message_bus.deliveries)

      matching_event = deliveries.find do |delivery|
        hash_including(attributes) == delivery.deep_stringify_keys
      end
      assert matching_event, "Didn't find event: \n\n #{attributes} \n\n in: #{deliveries.inspect}"
    end
    alias assert_published_event assert_event
  end
end

Streamy.message_bus = Streamy::MessageBuses::TestMessageBus.new
