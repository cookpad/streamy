module Streamy
  class PublicationFailedError < StandardError
    attr_reader :event_params, :error_class

    def initialize(original_error, event)
      @event_params = event.to_params
      @error_class = original_error.class
      super "Failed publishing event: #{event_params} \n#{error_class} - #{original_error.message}"
    end
  end
end
