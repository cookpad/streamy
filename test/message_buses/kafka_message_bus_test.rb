require "test_helper"
require "waterdrop"
require "streamy/message_buses/kafka_message_bus"

module Streamy
  class KafkaMessageBusTest < Minitest::Test
    attr_reader :bus

    def setup
      @bus = MessageBuses::KafkaMessageBus.new(@config || {})
      WaterDrop::Producer.any_instance.stubs(:produce_sync)
      WaterDrop::Producer.any_instance.stubs(:produce_async)
    end

    def teardown
      Thread.current[:streamy_kafka_sync_producer] = nil
    end

    def producer
      WaterDrop::Producer.any_instance
    end

    def build_producer
      WaterDrop::Producer.new
    end

    def example_delivery(priority)
      bus.deliver(
        payload: payload.to_s,
        key: "prk-sg-001",
        topic: "charcuterie",
        priority: priority
      )
    end

    def payload
      {
        type: "sausage",
        body: { meat: "pork", herbs: "sage" },
        event_time: "2018"
      }
    end

    def expected_event
      [
        payload: {
          type: "sausage",
          body: {
            meat: "pork",
            herbs: "sage"
          },
          event_time: "2018"
        }.to_s,
        key: "prk-sg-001",
        topic: "charcuterie"
      ]
    end

    def test_standard_priority_deliver
      producer.expects(:produce_async).with(*expected_event)
      example_delivery(:standard)
    end

    def test_low_priority_deliver
      producer.expects(:produce_async).with(*expected_event)
      example_delivery(:low)
    end

    def test_essential_priority_deliver
      producer.expects(:produce_sync).with(*expected_event)
      example_delivery(:essential)
    end

    def test_all_priority_delivery
      producer.expects(:produce_sync).with(*expected_event)
      example_delivery(:essential)

      producer.expects(:produce_async).with(*expected_event)
      example_delivery(:low)

      producer.expects(:produce_async).with(*expected_event)
      example_delivery(:standard)
    end

    def test_config_defaults
      bus.expects(:build_producer).with(
        "request.required.acks": -1,
        "request.timeout.ms": 5000,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2000,
        "queue.buffering.max.messages": 10_000,
        "queue.buffering.max.kbytes": 10_000
      ).returns(build_producer)

      example_delivery(:essential)

      bus.expects(:build_producer).with(
        "request.required.acks": -1,
        "request.timeout.ms": 5000,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2000,
        "queue.buffering.max.messages": 5_000,
        "queue.buffering.max.kbytes": 10_000,
        "queue.buffering.max.ms": 10_000,
        "batch.num.messages": 100
      ).returns(build_producer)

      example_delivery(:standard)
    end

    def test_config_overrides
      @config = {
        "request.timeout.ms": 2000,
        "socket.keepalive.enable": true
      }

      setup

      bus.expects(:build_producer).with(
        "request.required.acks": -1,
        "request.timeout.ms": 2000,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2000,
        "queue.buffering.max.messages": 10_000,
        "queue.buffering.max.kbytes": 10_000,
        "socket.keepalive.enable": true
      ).returns(build_producer)

      example_delivery(:essential)

      bus.expects(:build_producer).with(
        "request.required.acks": -1,
        "request.timeout.ms": 2000,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2000,
        "queue.buffering.max.messages": 5000,
        "queue.buffering.max.kbytes": 10_000,
        "queue.buffering.max.ms": 10_000,
        "batch.num.messages": 100,
        "socket.keepalive.enable": true
      ).returns(build_producer)

      example_delivery(:standard)
    end

    def test_sync_producer_shutdown
      example_delivery(:essential)

      producer.expects(:close)

      bus.shutdown
    end

    def test_async_producer_shutdown
      example_delivery(:standard)

      producer.expects(:close)

      bus.shutdown
    end
  end
end
