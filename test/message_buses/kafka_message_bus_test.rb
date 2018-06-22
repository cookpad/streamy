require "test_helper"

module Streamy
  class KafkaMessageBusTest < Minitest::Test
    def setup
      # Needed to teardown properly
      Thread.current[:streamy_kafka_sync_producer] = nil

      @kafka = mock('kafka')
      @async_producer = mock('async_producer')
      kafka.stubs(:async_producer).returns(async_producer)
      @sync_producer = mock('sync_producer')
      kafka.stubs(:producer).returns(sync_producer)
      Kafka.stub :new, @kafka do
        @bus = MessageBuses::KafkaMessageBus.new({})
      end
    end

    def example_delivery(priority)
      bus.deliver(
        key: "prk-sg-001",
        type: "sausage",
        topic: "charcuterie",
        event_time: "2018",
        body: { meat: "pork", herbs: "sage" },
        priority: priority,
      )
    end

    def expected_event
      [
        {
          type: "sausage",
          body: {
            meat: "pork",
            herbs: "sage",
          },
          event_time: "2018",
        }.to_json,
        key: "prk-sg-001",
        topic: "charcuterie",
      ]
    end

    def stub_producers
      sync_producer.stubs(:produce)
      sync_producer.stubs(:deliver_messages)
      async_producer.stubs(:produce)
      async_producer.stubs(:deliver_messages)
    end

    attr_reader :bus, :kafka, :async_producer, :sync_producer

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

    def test_all_priority_delivery
      sync_producer.expects(:produce).with(*expected_event)
      sync_producer.expects(:deliver_messages)
      example_delivery(:essential)

      async_producer.expects(:produce).with(*expected_event)
      example_delivery(:low)

      async_producer.expects(:produce).with(*expected_event)
      async_producer.expects(:deliver_messages)
      example_delivery(:standard)
    end

    def test_config
      stub_producers

      kafka.expects(:producer).with(
         required_acks:       -1,
         ack_timeout:         5,
         max_retries:         2,
         retry_backoff:       1,
         max_buffer_size:     1000,
         max_buffer_bytesize: 10_000_000,
      ).returns(sync_producer)

      example_delivery(:essential)

      kafka.expects(:async_producer).with(
         max_queue_size:      1000,
         delivery_threshold:  100,
         delivery_interval:   2,
         required_acks:       -1,
         ack_timeout:         5,
         max_retries:         2,
         retry_backoff:       1,
         max_buffer_size:     1000,
         max_buffer_bytesize: 10_000_000,
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
