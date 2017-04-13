module Streamy
  class DummyMessageBus
    cattr_accessor :deliveries do
      []
    end

    def deliver(params = {})
      self.deliveries << params
    end
  end
end
