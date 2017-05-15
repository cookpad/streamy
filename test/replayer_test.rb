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

module Streamy
  class ReplayerTest < Minitest::Test
    def test_retrieving_and_replaying_past_events
      # TODO: This spec is tied to using redshift
      key = "UUID"
      topic = "bookmarks"
      type = "bookmarked_recipe"
      body = { recipe_id: 1, recipe_author_id: 2 }.to_json
      event_time = "2017-01-04 19:00:00 +0000"
      row = [key, topic, type, body, event_time]

      RedshiftConnector.expects(:foreach).yields(row)

      Replayer.new(from: "2014-09-15", topics: %w(bookmarks)).run

      assert_equal EventHandlers::BookmarkedRecipe.debug.last, { recipe_id: 1, recipe_author_id: 2 }
    end
  end
end
