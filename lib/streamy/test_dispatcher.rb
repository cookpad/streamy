module Streamy
  class TestDispatcher < Dispatcher
    cattr_accessor :events do
      []
    end

    def dispatch
      super
      events << event_params
    end
  end
end
