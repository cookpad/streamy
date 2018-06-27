module Streamy
  class EventHandlerNotFoundError < StandardError
    def initialize(handler_class_name)
      super "No event handler found for #{handler_class_name}"
    end
  end
end
