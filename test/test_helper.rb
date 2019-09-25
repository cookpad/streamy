$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "streamy"
require "minitest/autorun"
require "minitest/focus"
require "mocha/minitest"
require "streamy/helpers/minitest_helper"

def assert_runtime_error(message, &block)
  error = assert_raises RuntimeError do
    yield
  end

  assert_equal message, error.message
end

def assert_delivered_message(params)
  assert_equal Streamy.dispatcher.messages.last, params
end

def assert_deserialized_message(params)
  deserializer = Streamy::Deserializers::AvroDeserializer.new
  assert_equal deserializer.call(Streamy.dispatcher.messages.last), params
end

Streamy.logger = Logger.new("test.log")
