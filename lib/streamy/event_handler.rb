module Streamy
  class EventHandler
    def initialize(attributes)
      @attributes = attributes
    end

    def process
      raise "Not implemented"
    end

    private

      attr_reader :attributes

      def event_time
        attributes[:event_time]
      end

      def body
        attributes[:body]
      end
  end
end
