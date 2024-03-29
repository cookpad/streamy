module Streamy
  class PublicationFailedError < StandardError
    attr_reader :event_params

    def initialize(original_error, event)
      @event_params = event.to_params
      message = <<~TEXT
        Failed publishing event: #{event_params}
        #{original_error.class} - #{original_error.message}, caused by  #{original_error.try(:cause)}
      TEXT
      super message
    end
  end
end
