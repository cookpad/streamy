require "webmock/minitest"

class ActiveSupport::TestCase
  # TODO: Bit rough, needs better debug output
  def assert_published_event(attributes = {})
    matching_event = Streamy.message_bus.deliveries.find do |delivery|
      hash_including(attributes) == delivery.deep_stringify_keys
    end
    assert matching_event
  end
end

Streamy.message_bus = Streamy::MessageBuses::TestMessageBus.new
