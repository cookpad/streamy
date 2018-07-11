module Streamy
  # External
  # TODO: Move into classes that use them
  require "active_support"
  require "active_support/core_ext/string"

  require "streamy/version"
  require "streamy/consumer"
  require "streamy/event"
  require "streamy/event_handler"
  require "streamy/message_processor"
  require "streamy/profiler"
  require "streamy/simple_logger"

  # Errors
  require "streamy/errors/event_handler_not_found_error"
  require "streamy/errors/publication_failed_error"
  require "streamy/errors/type_not_found_error"

  # Message Buses
  require "streamy/message_buses/message_bus"
  require "streamy/message_buses/test_message_bus"

  # Rake task
  require "streamy/railtie" if defined?(Rails)

  class << self
    attr_accessor :message_bus, :worker, :logger, :cache

    def shutdown
      message_bus.try(:shutdown)
    end
  end

  self.logger = SimpleLogger.new
end

at_exit { Streamy.shutdown }
