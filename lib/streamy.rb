require "streamy/version"
require "streamy/event"
require "streamy/exporter"
require "streamy/dummy_message_bus"
require "streamy/file_message_bus"
require "streamy/fluent_message_bus"
require "streamy/profiler"
require "streamy/simple_logger"
require "streamy/uploader"

module Streamy
  class << self
    attr_accessor :message_bus
  end
end
