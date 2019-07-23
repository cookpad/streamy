require "test_helper"

module Streamy
  class DummyHandler < Streamy::EventHandler
    def run
      body
    end
  end

  class EventHandlerTest < Minitest::Test
    def test_accessing_body_as_hash
      assert_equal "Title", DummyHandler.run(event)[:title]
    end

    def test_accessing_body_as_hash_with_string_key
      assert_equal "Title", DummyHandler.run(event)["title"]
    end

    def test_accessing_body_as_object
      assert_equal "Title", DummyHandler.run(event).title
    end

    private

      def event
        { body: { title: "Title" } }
      end
  end
end
