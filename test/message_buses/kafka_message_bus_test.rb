require "test_helper"
require "karafka"
require "streamy/message_buses/kafka_message_bus"

module Streamy
  class KafkaMessageBusTest < Minitest::Test
    attr_reader :bus, :async_producer, :sync_producer

    def setup # rubocop:disable Metrics/AbcSize
      @bus = MessageBuses::KafkaMessageBus.new(@config || {})
      @async_producer = mock("async_producer")
      @sync_producer = mock("sync_producer")
      sync_producer.stubs(:produce_sync)
      async_producer.stubs(:produce_async)
    end

    def teardown
      Thread.current[:streamy_kafka_sync_producer] = nil
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

    def stub_producers
      bus.stubs(:build_async_producer).returns(async_producer)
      bus.stubs(:build_sync_producer).returns(sync_producer)
    end

    def test_standard_priority_deliver
      stub_producers
      async_producer.expects(:produce_async).with(*expected_event)
      example_delivery(:standard)
    end

    def test_low_priority_deliver
      stub_producers
      async_producer.expects(:produce_async).with(*expected_event)
      example_delivery(:low)
    end

    def test_essential_priority_deliver
      stub_producers
      sync_producer.expects(:produce_sync).with(*expected_event)
      example_delivery(:essential)
    end

    def test_all_priority_delivery # rubocop:disable Metrics/AbcSize
      stub_producers

      sync_producer.expects(:produce_sync).with(*expected_event)
      example_delivery(:essential)

      async_producer.expects(:produce_async).with(*expected_event)
      example_delivery(:low)

      async_producer.expects(:produce_async).with(*expected_event)
      example_delivery(:standard)
    end

    def test_config_defaults
      bus.expects(:build_producer).with(
        "bootstrap.servers": "localhost:9092",
        "request.required.acks": -1,
        "request.timeout.ms": 5,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2,
        "queue.buffering.max.messages": 10_000,
        "queue.buffering.max.kbytes": 10_000
      ).returns(sync_producer)

      example_delivery(:essential)

      bus.expects(:build_producer).with(
        max_queue_size: 5_000,
        delivery_threshold: 100,
        delivery_interval: 10,
        "bootstrap.servers": "localhost:9092",
        "request.required.acks": -1,
        "request.timeout.ms": 5,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2,
        "queue.buffering.max.messages": 10_000,
        "queue.buffering.max.kbytes": 10_000
      ).returns(async_producer)

      example_delivery(:standard)
    end

    def test_config_overrides
      @config = {
        "request.timeout.ms": 2,
        "socket.keepalive.enable": true
      }

      setup

      bus.expects(:build_producer).with(
        "bootstrap.servers": "localhost:9092",
        "request.required.acks": -1,
        "request.timeout.ms": 2,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2,
        "queue.buffering.max.messages": 10_000,
        "queue.buffering.max.kbytes": 10_000,
        "socket.keepalive.enable": true
      ).returns(sync_producer)

      example_delivery(:essential)

      bus.expects(:build_producer).with(
        max_queue_size: 5_000,
        delivery_threshold: 100,
        delivery_interval: 10,
        "bootstrap.servers": "localhost:9092",
        "request.required.acks": -1,
        "request.timeout.ms": 2,
        "message.send.max.retries": 30,
        "retry.backoff.ms": 2,
        "queue.buffering.max.messages": 10_000,
        "queue.buffering.max.kbytes": 10_000,
        "socket.keepalive.enable": true
      ).returns(async_producer)

      example_delivery(:standard)
    end

    def test_shutdown
      stub_producers

      example_delivery(:essential)
      example_delivery(:standard)

      async_producer.expects(:shutdown)
      sync_producer.expects(:shutdown)

      bus.shutdown
    end
  end
end
