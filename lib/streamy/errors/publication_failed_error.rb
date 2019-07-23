module Streamy
  class PublicationFailedError < StandardError
    attr_reader :event_params

    def initialize(original_error, event)
      @event_params = event.to_params
      super "Failed publishing event: #{event_params} \n#{original_error.class} - #{original_error.message}"
    end
  end
end
