require "test_helper"
require "streamy/message_buses/kafka_message_bus"

module Streamy
  class KafkaMessageBusTest < Minitest::Test
    attr_reader :bus, :kafka, :async_producer, :sync_producer

    def setup # rubocop:disable Metrics/AbcSize
      @kafka = mock("kafka")
      @async_producer = mock("async_producer")
      kafka.stubs(:async_producer).returns(async_producer)
      @sync_producer = mock("sync_producer")
      kafka.stubs(:producer).returns(sync_producer)
      Kafka.stubs(:new).returns(kafka)
      @bus = MessageBuses::KafkaMessageBus.new(@config || {})
    end

    def teardown
      Thread.current[:streamy_kafka_sync_producer] = nil
    end

    def example_delivery(priority)
      bus.deliver(
        payload: payload,
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
      }.to_json
    end

    def expected_event
      [
        {
          type: "sausage",
          body: {
            meat: "pork",
            herbs: "sage"
          },
          event_time: "2018"
        }.to_json,
        key: "prk-sg-001",
        topic: "charcuterie"
      ]
    end

    def stub_producers
      sync_producer.stubs(:produce)
      sync_producer.stubs(:deliver_messages)
      async_producer.stubs(:produce)
      async_producer.stubs(:deliver_messages)
    end

    def test_standard_priority_deliver
      async_producer.expects(:produce).with(*expected_event)
      async_producer.expects(:deliver_messages)
      example_delivery(:standard)
    end

    def test_low_priority_deliver
      async_producer.expects(:produce).with(*expected_event)
      example_delivery(:low)
    end

    def test_essential_priority_deliver
      sync_producer.expects(:produce).with(*expected_event)
      sync_producer.expects(:deliver_messages)
      example_delivery(:essential)
    end

    def test_batched_priority_deliver # rubocop:disable Metrics/AbcSize
      sync_producer.stubs(:buffer_size).returns(9998)
      sync_producer.expects(:produce).with(*expected_event)
      example_delivery(:batched)

      sync_producer.stubs(:buffer_size).returns(9999)
      sync_producer.expects(:produce).with(*expected_event)
      example_delivery(:batched)

      sync_producer.stubs(:buffer_size).returns(10000)
      sync_producer.expects(:produce).with(*expected_event)
      sync_producer.expects(:deliver_messages)
      example_delivery(:batched)
    end

    def test_manually_deliver_batched_messages
      sync_producer.stubs(:buffer_size).returns(0)
      sync_producer.expects(:produce).with(*expected_event)
      example_delivery(:batched)

      sync_producer.expects(:deliver_messages)
      bus.sync_producer_deliver_messages
    end

    def test_all_priority_delivery # rubocop:disable Metrics/AbcSize
      sync_producer.expects(:produce).with(*expected_event)
      sync_producer.expects(:deliver_messages)
      example_delivery(:essential)

      async_producer.expects(:produce).with(*expected_event)
      example_delivery(:low)

      async_producer.expects(:produce).with(*expected_event)
      async_producer.expects(:deliver_messages)
      example_delivery(:standard)

      sync_producer.stubs(:buffer_size).returns(10000)
      sync_producer.expects(:produce).with(*expected_event)
      sync_producer.expects(:deliver_messages)
      example_delivery(:batched)
    end

    def test_config_defaults
      stub_producers

      kafka.expects(:producer).with(
        required_acks:       -1,
        ack_timeout:         5,
        max_retries:         30,
        retry_backoff:       2,
        max_buffer_size:     10_000,
        max_buffer_bytesize: 10_000_000
      ).returns(sync_producer)

      example_delivery(:essential)

      kafka.expects(:async_producer).with(
        max_queue_size:      5_000,
        delivery_threshold:  100,
        delivery_interval:   10,
        required_acks:       -1,
        ack_timeout:         5,
        max_retries:         30,
        retry_backoff:       2,
        max_buffer_size:     10000,
        max_buffer_bytesize: 10_000_000
      ).returns(async_producer)

      example_delivery(:standard)
    end

    def test_config_overides
      @config = {
        max_queue_size:      1,
        delivery_threshold:  1,
        delivery_interval:   1,
        required_acks:       1,
        ack_timeout:         1,
        max_retries:         1,
        retry_backoff:       1,
        max_buffer_size:     1,
        max_buffer_bytesize: 1
      }

      setup

      stub_producers

      kafka.expects(:producer).with(
        required_acks:       1,
        ack_timeout:         1,
        max_retries:         1,
        retry_backoff:       1,
        max_buffer_size:     1,
        max_buffer_bytesize: 1
      ).returns(sync_producer)

      example_delivery(:essential)

      kafka.expects(:async_producer).with(
        max_queue_size:      1,
        delivery_threshold:  1,
        delivery_interval:   1,
        required_acks:       1,
        ack_timeout:         1,
        max_retries:         1,
        retry_backoff:       1,
        max_buffer_size:     1,
        max_buffer_bytesize: 1
      ).returns(async_producer)

      example_delivery(:standard)
    end

    def test_client_config
      producer_config = {
        max_queue_size:      2,
        delivery_threshold:  2,
        delivery_interval:   2,
        required_acks:       2,
        ack_timeout:         2,
        max_retries:         2,
        retry_backoff:       2,
        max_buffer_size:     2,
        max_buffer_bytesize: 2
      }

      client_config = {
        client_id: "test",
        seed_brokers: "test-broker:9092",
        sasl_plain_username: "tester",
        sasl_plain_password: "blue",
        ssl_ca_certs_from_system: true,
        logger: Streamy.logger
      }

      config = client_config.merge(producer_config)

      Kafka.expects(:new).with(client_config)
      MessageBuses::KafkaMessageBus.new(config)
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
