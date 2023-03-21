module Streamy
  # External
  # TODO: Move into classes that use them
  require "active_support"
  require "active_support/core_ext/string"
  require "active_support/notifications"

  require "streamy/version"
  require "streamy/configuration"
  require "streamy/consumer"
  require "streamy/event_handler"
  require "streamy/message_processor"
  require "streamy/profiler"
  require "streamy/simple_logger"

  # Event types
  require "streamy/event"
  require "streamy/json_event"
  require "streamy/avro_event"

  # Deserializers
  require "streamy/deserializers/avro_deserializer"

  # Errors
  require "streamy/errors/event_handler_not_found_error"
  require "streamy/errors/publication_failed_error"
  require "streamy/errors/type_not_found_error"
  require "streamy/errors/unknown_priority_error"
  require "streamy/errors/unknown_producer_type_error"

  # Message Buses
  require "streamy/message_buses/message_bus"

  class << self
    attr_accessor :message_bus, :logger, :dispatcher, :notifications_bus,
      :notifications_bus_namespace, :max_wait_timeout

    def shutdown
      message_bus.try(:shutdown)
    end
  end

  self.message_bus = MessageBuses::MessageBus.new
  self.logger = SimpleLogger.new
  self.dispatcher = Dispatcher
  self.notifications_bus = ::ActiveSupport::Notifications
  self.notifications_bus_namespace = :kafka
  self.max_wait_timeout = 5

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

at_exit { Streamy.shutdown }
