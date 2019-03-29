require "test_helper"

class StreamyTest < Minitest::Test
  def test_shutdown
    Streamy.message_bus.expects(:shutdown)
    Streamy.shutdown
  end

  def test_shutdown_unsupported_message_bus
    Streamy.shutdown
  end
end
