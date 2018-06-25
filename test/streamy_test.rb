require "test_helper"

class StreamyTest < Minitest::Test
  def setup
    @message_bus = mock("message_bus")
    Streamy.message_bus = @message_bus
  end

  def test_shutdown
    @message_bus.expects(:shutdown)
    Streamy.shutdown
  end

  def test_shutdown_unsupported_message_bus
    Streamy.shutdown
  end
end
