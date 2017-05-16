require "test_helper"

module EventHandlers
  class BookmarkedRecipe < Streamy::EventHandler
    cattr_accessor :debug
    self.debug = []

    def process
      self.debug << body.symbolize_keys
    end
  end
end

class DummyMessageProcessor < Streamy::MessageProcessor
  def process
    super
  rescue Streamy::EventHandlerNotFoundError
  end
end

module Streamy
  class ReplayerTest < Minitest::Test
    def setup
      Streamy.message_processor = DummyMessageProcessor
    end

    def test_retrieving_and_replaying_past_events
      # TODO: This spec is tied to using redshift
      key = "UUID"
      topic = "bookmarks"
      type = "bookmarked_recipe"
      body = { recipe_id: 1, recipe_author_id: 2 }.to_json
      event_time = "2017-01-04 19:00:00 +0000"
      row = [key, topic, type, body, event_time]

      stub_event_store(row)

      Replayer.new(from: "2014-09-15", topics: %w(bookmarks)).run

      assert_equal EventHandlers::BookmarkedRecipe.debug.last, { recipe_id: 1, recipe_author_id: 2 }
    end

    def test_ignoring_unknown_events_with_custom_message_processor
      topic = "bookmarks"
      type = "unknown_event"
      row = [nil, topic, type, nil, nil]

      stub_event_store(row)

      Replayer.new(topics: "bookmarks").run
    end

    private

      def stub_event_store(result)
        RedshiftConnector.expects(:foreach).yields(result)
      end
  end
end
