module Streamy
  module Consumer
    def process(message)
      MessageProcessor.new(message).run
    end
  end
end
