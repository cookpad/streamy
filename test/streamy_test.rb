require "test_helper"

class StreamyTest < Minitest::Test
  def test_shutdown
    Streamy.message_bus.expects(:shutdown)
    Streamy.shutdown
  end

  def test_shutdown_unsupported_message_bus
    Streamy.shutdown
  end

  def test_bulk_deliver
    Streamy.bulk_deliver do
      # do nothing
    end
  end
end
