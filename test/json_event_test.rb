require "test_helper"

module Streamy
  class JsonEventTest < Minitest::Test
    class TestEvent < JsonEvent
      def topic
        :bacon
      end

      def body
        {
          smoked: "true",
          streaky: "false"
        }
      end

      def event_time
        "nowish"
      end
    end

    def test_publish
      SecureRandom.stubs(:uuid).returns("IAMUUID")

      TestEvent.publish

      assert_published_event(
        key: "IAMUUID",
        topic: :bacon,
        payload: {
          type: "test_event",
          body: { smoked: "true", streaky: "false" },
          event_time: "nowish"
        }.to_json
      )
    end
  end
end
