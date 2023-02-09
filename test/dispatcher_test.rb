require "test_helper"
require_relative "./event_test"

class DispatcherTest < Minitest::Test
  def test_dispatcher
    event = ::Streamy::EventTest::ValidEvent.new
    assert_nil ::Streamy::Dispatcher.new(event).dispatch
  end
end
