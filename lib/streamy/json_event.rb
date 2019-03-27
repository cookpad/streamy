module Streamy
  class JsonEvent < Event
    def payload
      {
        type: type,
        body: body,
        event_time: event_time
      }.to_json
    end
  end
end
