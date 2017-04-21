require "test_helper"

module Streamy
  class MessageTest < Minitest::Test
    def test_creating_from_redshift
      message = Message.new_from_redshift("key", "topic", "type", '{"key":"value"}', "event_time")
      assert_equal "key", message.key
      assert_equal "value", message.body["key"]
    end

    def test_base_64_decoding_from_kinesis
      assert_equal "bookmarks", fixture.topic
      assert_equal "a8ee7b85-b8df-43dc-9198-adcb93479d60", fixture.key
      assert fixture.body.present?
    end

    private

      def fixture
        @_fixture ||= Message.new_from_base64(base64)
      end

      def base64
        "
eyJjb3VudHJ5IjoiVVMiLCJsYW5ndWFnZSI6ImVuIiwicHJvdmlkZXJfaWQiOiIxIiwia2V5IjoiYThlZTdiODUtYjhkZi00M2RjLTkxOTgtYWRjYjkzNDc5ZDYwIiwidG9waWMiO\
iJib29rbWFya3MiLCJ0eXBlIjoiYm9va21hcmtlZF9yZWNpcGUiLCJib2R5Ijp7InJlY2lwZV9pZCI6MTg4NDgwOSwicmVjaXBlX2F1dGhvcl9pZCI6MzEwNjYxMSwiYm9va21hcm\
tfaWQiOjUyMDgxMjI1LCJib29rbWFya2VyX2lkIjo2NTE2OTc0fSwiZXZlbnRfdGltZSI6IjIwMTctMDMtMjIgMDc6NDg6NDcgVVRDIiwiZXZlbnQiOiJkb21haW5fZXZlbnQiLCJ\
0aW1lc3RhbXAiOiIxNDkwMTY4OTI3IiwidGFnIjoidGQuZ2xvYmFsX3N0YWdpbmcuZG9tYWluX2V2ZW50cyJ9"
      end
  end
end
