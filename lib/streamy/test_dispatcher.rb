module Streamy
  class TestDispatcher < Dispatcher
    cattr_accessor :events do
      []
    end

    cattr_accessor :messages do
      []
    end

    def dispatch
      events << event_params
      messages << message_params
    end

    def self.dispatch_many(events)
      self.events += events.map(&:to_params)
      self.messages += events.map(&:to_message)
    end
  end
end
