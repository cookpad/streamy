# External
# TODO: Move into classes that use them
require "active_support"
require "active_record"
require "redshift-connector"
require "fluent-logger"

require "streamy/version"
require "streamy/event"
require "streamy/event_handler"
require "streamy/message"
require "streamy/message_processor"
require "streamy/replayer"
require "streamy/profiler"
require "streamy/simple_logger"

# Message Buses
require "streamy/message_buses/test_message_bus"
require "streamy/message_buses/file_message_bus"
require "streamy/message_buses/fluent_message_bus"

# Event stores
require "streamy/event_stores/copy_buffered_redshift_store"

require "streamy/railtie" if defined?(Rails)

module Streamy
  class << self
    attr_accessor :message_bus, :event_store, :message_processor, :logger, :consumer_properties
  end

  self.logger = SimpleLogger.new
  self.message_processor =  MessageProcessor
end
