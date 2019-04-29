module Streamy
  # External
  # TODO: Move into classes that use them
  require "active_support"
  require "active_support/core_ext/string"

  require "streamy/version"
  require "streamy/configuration"
  require "streamy/consumer"
  require "streamy/event"
  require "streamy/json_event"
  require "streamy/avro_event"
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

  require "avro_patches"
  require "avro_turf/messaging"

  class << self
    attr_accessor :message_bus, :worker, :logger, :cache

    def shutdown
      message_bus.try(:shutdown)
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.avro_messaging
    @_avro_messaging ||= AvroTurf::Messaging.new(
      registry_url: Streamy.configuration.avro_schema_registry_url,
      schemas_path: Streamy.configuration.avro_schemas_path,
      logger: ::Streamy.logger
    )
  end

  self.logger = SimpleLogger.new
end

at_exit { Streamy.shutdown }
