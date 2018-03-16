module Streamy
  class PublicationFailedError < StandardError
    attr_reader :event_params

    def initialize(original_error, **event_params)
      @event_params = event_params
      super "Failed publishing event: #{event_params} \n#{original_error.class} - #{original_error.message}"
    end
  end
end
