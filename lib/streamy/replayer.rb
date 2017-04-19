module Streamy
  class Replayer
    def initialize(start_time: nil, topics: [])
      @start_time = start_time
      @topics = topics
    end

    def run
      entries.find_each do |entry|
        Streamy.logger.info "importing #{entry}"
        yield(entry)
      end
    end

    private

      attr_reader :start_time, :topics

      def entries
        Streamy.event_store.entries.order(event_time: :asc).where("event_time >= ?", start_time).where(topic: topics)
      end
  end
end
