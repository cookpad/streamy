require "streamy/helpers/consumer_macros"
require "webmock/minitest"

class ActiveSupport::TestCase
  include Streamy::Helpers::ConsumerMacros

  # TODO: Bit rough, needs better debug output
  def assert_published_event(attributes = {})
    matching_event = Streamy.message_bus.deliveries.find do |delivery|
      hash_including(attributes) == delivery.deep_stringify_keys
    end
    assert matching_event
  end
end

Streamy.message_bus = Streamy::MessageBuses::TestMessageBus.new
