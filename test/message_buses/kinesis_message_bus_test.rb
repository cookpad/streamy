require "test_helper"

module Streamy
  module MessageBuses
    class KinesisMessageBusTest < Minitest::Test
      def setup
        KinesisMessageBus.any_instance.stubs(:client).returns(kinesis)
      end

      def test_deliver
        kinesis.expects(:put_record)

        bus.deliver(
          key: "key_name",
          topic: "topic_name",
          type: "event_name",
          body: "{}",
          event_time: "2017-01-01"
        )
      end

      def test_deliver_now
        kinesis.expects(:put_record)

        bus.deliver_now(
          key: "key_name",
          topic: "topic_name",
          type: "event_name",
          body: "{}",
          event_time: "2017-01-01"
        )
      end

      private

        def bus
          @_bus ||= KinesisMessageBus.new("stream_name")
        end

        def kinesis
          @_kinesis ||= mock
        end
    end
  end
end
