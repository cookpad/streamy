module Streamy
  # External
  # TODO: Move into classes that use them
  require "active_support"
  require "active_support/core_ext/string"

  require "streamy/version"
  require "streamy/event"
  require "streamy/event_handler"
  require "streamy/message_processor"
  require "streamy/profiler"
  require "streamy/simple_logger"

  # Consumers
  require "streamy/consumers/rabbit_consumer"
  require "streamy/consumers/kafka_consumer"

  # Errors
  require "streamy/errors/event_handler_not_found_error"
  require "streamy/errors/publication_failed_error"
  require "streamy/errors/type_not_found_error"

  # Message Buses
  require "streamy/message_buses/message_bus"
  require "streamy/message_buses/test_message_bus"
  require "streamy/message_buses/rabbit_message_bus"
  require "streamy/message_buses/rabbit_message_bus/message"
  require "streamy/message_buses/kafka_message_bus"

  # Workers
  require "streamy/workers/rabbit_worker"
  require "streamy/workers/kafka_worker"

  # Rake task
  require "streamy/railtie" if defined?(Rails)

  class << self
    attr_accessor :message_bus, :worker, :logger, :cache
  end

  self.logger = SimpleLogger.new
end
