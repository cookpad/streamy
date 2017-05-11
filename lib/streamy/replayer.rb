module Streamy
  class Replayer
    def initialize(from: nil, topics: [])
      @from = from
      @topics = topics
    end

    def run
      entries.find_each do |row|
        Streamy.logger.info "importing #{row}"
        message = Message.new_from_redshift(*row)
        Streamy.message_processor.process(message)
      end
    end

    private

      attr_reader :from, :topics

      def entries
        Streamy.
          event_store.
          entries.
          select(:key, :topic, :type, :body, :event_time).
          where(topic: topics).
          where("event_time >= ?", from).
          order(event_time: :asc)
      end
  end
end
