module Streamy
  class Replayer
    def initialize(start_time: nil, topics: [])
      @start_time = start_time
      @topics = topics
    end

    def run
      entries.buffered do |row|
        Streamy.logger.info "importing #{row}"
        message = Message.new_from_redshift(*row)
        Streamy.message_processor.process(message)
      end
    end

    private

      attr_reader :start_time, :topics

      def entries
        Streamy.
          event_store.
          entries.
          select(:key, :topic, :type, :body, :event_time).
          where(topic: topics).
          where("event_time >= ?", start_time).
          order(event_time: :asc)
      end
  end
end
