require "test_helper"

module Streamy
  class RabbitMessageBusTest < Minitest::Test
    def setup
      Hutch::Logging.logger = stub(info: true, error: true)
    end

    def test_deliver
      bus = MessageBuses::RabbitMessageBus.new(uri: "valid_uri")

      Hutch.expects(:connect)
      Hutch.expects(:publish).with("global.topic.type", key: "key", topic: "topic", type: "type", body: "body", event_time: "2018")

      bus.deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: "2018")
    end

    def test_connection_error
      bus = MessageBuses::RabbitMessageBus.new(uri: "broken_uri")

      error = assert_raises(PublicationFailedError) do
        bus.deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: Time.now)
      end

      assert_match(/ConnectionError/, error.message)
    end
  end
end
