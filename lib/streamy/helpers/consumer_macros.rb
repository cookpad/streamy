module Streamy
  module Helpers
    module ConsumerMacros
      def consume(**attributes)
        message = Message.new(**attributes)
        Streamy.message_processor.process(message)
      end
    end
  end
end
