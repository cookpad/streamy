require "test_helper"
require "streamy/message_buses/rabbit_message_bus"

module Streamy
  class RabbitMessageBusTest < Minitest::Test
    def test_deliver
      bus = MessageBuses::RabbitMessageBus.new(uri: "valid_uri")

      Hutch.expects(:connect)
      Hutch.expects(:publish).with(
        "topic.type",
        key: "key",
        topic: "topic",
        type: "type",
        body: "body",
        event_time: "2018"
      )

      bus.deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: "2018", priority: nil)
    end

    def test_deliver_with_custom_routing_prefix
      bus = MessageBuses::RabbitMessageBus.new(uri: "valid_uri", routing_key_prefix: "replay.global")

      Hutch.expects(:connect)
      Hutch.expects(:publish).with(
        "replay.global.topic.type",
        key: "key",
        topic: "topic",
        type: "type",
        body: "body",
        event_time: "2018"
      )

      bus.deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: "2018", priority: nil)
    end
  end
end
