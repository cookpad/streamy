module Streamy
  DEFAULT_TOPIC_PREFIX = "global"

  # External
  # TODO: Move into classes that use them
  require "active_support"

  require "streamy/version"
  require "streamy/consumer"
  require "streamy/event"
  require "streamy/event_handler"
  require "streamy/message_processor"
  require "streamy/profiler"
  require "streamy/simple_logger"

  # Errors
  require "streamy/errors/event_handler_not_found_error"
  require "streamy/errors/type_not_found_error"

  # Message Buses
  require "streamy/message_buses/test_message_bus"
  require "streamy/message_buses/rabbit_message_bus"

  # Rake task
  require "streamy/railtie" if defined?(Rails)

  class << self
    attr_accessor :message_bus, :logger
  end

  self.logger = SimpleLogger.new
end
