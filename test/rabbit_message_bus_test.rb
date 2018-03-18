require "test_helper"

module Streamy
  class RabbitMessageBusTest < Minitest::Test
    def test_deliver
      bus = MessageBuses::RabbitMessageBus.new(uri: "valid_uri")

      Hutch.expects(:connect)
      Hutch.expects(:publish).with("global.topic.type", key: "key", topic: "topic", type: "type", body: "body", event_time: "2018")

      bus.deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: "2018")
    end
  end
end
