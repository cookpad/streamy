require "test_helper"

module Streamy
  class ReplayerTest < Minitest::Test
    def test_retrieving_and_replaying_past_events
      key = "UUID"
      topic = "bookmarks"
      type = "bookmarked_recipe"
      body = { recipe_id: 1, recipe_author_id: 2 }.to_json
      event_time = "2017-01-04 19:00:00 +0000"
      row = [key, topic, type, body, event_time]

      RedshiftConnector.expects(:foreach).yields(row)

      Replayer.new(from: "2014-09-15").run

      #assert_equal 1, RecipeReport.where(recipe_id: 1).count
      #assert_equal 1, AuthorReport.where(author_id: 2).count
      #assert_equal "bookmarks", MessageLog.first.topic
    end
  end
end
