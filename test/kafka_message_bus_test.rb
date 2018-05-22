require "test_helper"

module Streamy
  class KafkaMessageBusTest < Minitest::Test
    def test_deliver
      bus = MessageBuses::KafkaMessageBus.new

      obj = Kafka.new(seed_brokers: ["127.0.0.1:9092"], client_id: "default_app_name")
      parameters = [
        {
          key: "key",
          type: "type",
          body: "body",
          event_time: "2018"
        },
        topic: "topic"
      ]
      assert_send([obj, :deliver_message, *parameters])

      bus.deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: "2018")
    end
  end
end
