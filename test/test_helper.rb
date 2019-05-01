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

Streamy.logger = Logger.new("test.log")
