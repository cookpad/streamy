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
  end
end
