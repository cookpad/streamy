require "webmock/minitest"

class ActiveSupport::TestCase
  def assert_published_event(attributes = {})
    deliveries = Streamy.message_bus.deliveries

    matching_event = deliveries.find do |delivery|
      hash_including(attributes) == delivery.deep_stringify_keys
    end
    assert matching_event, "Didn't find event: \n\n #{attributes} \n\n in: #{deliveries.inspect}"
  end
end

Streamy.message_bus = Streamy::MessageBuses::TestMessageBus.new
