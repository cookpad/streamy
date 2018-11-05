module Streamy
  class MessageProcessor
    def initialize(message)
      @message = message.with_indifferent_access
    end

    def run
      event_handler.new(body).process
    end

    private

      attr_reader :message

      def event_handler
        handler_class_name.safe_constantize || raise(handler_not_found_error)
      end

      def handler_class_name
        "#{message_type.camelize}Handler"
      end

      def message_type
        message[:type] || raise(TypeNotFoundError)
      end

      def handler_not_found_error
        EventHandlerNotFoundError.new(handler_class_name)
      end

      def body
        message[:body] || {}
      end
  end
end
