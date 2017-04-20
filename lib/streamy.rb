require "streamy/version"
require "streamy/event"
require "streamy/event_processor"
require "streamy/profiler"
require "streamy/replayer"
require "streamy/simple_logger"

# Message Buses
require "streamy/message_buses/test_message_bus"
require "streamy/message_buses/file_message_bus"
require "streamy/message_buses/fluent_message_bus"

# Event stores
require "streamy/event_stores/copy_buffered_redshift_store"


module Streamy
  class << self
    attr_accessor :message_bus, :event_store, :logger
  end

  self.logger = SimpleLogger.new
end
