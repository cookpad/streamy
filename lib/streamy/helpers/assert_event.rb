require "webmock/minitest"
require "streamy/test_dispatcher"

module Streamy
  module AssertEvent
    def assert_event(attributes = {})
      events = TestDispatcher.events

      matching_event = events.find do |event|
        hash_including(attributes) == event.deep_stringify_keys
      end
      assert matching_event, "Didn't find event: \n\n #{attributes} \n\n in: #{events.inspect}"
    end
    alias assert_published_event assert_event
  end

  Streamy.dispatcher = TestDispatcher
end
