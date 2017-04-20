module Streamy
  class Replayer
    def initialize(start_time: nil, topics: [])
      @start_time = start_time
      @topics = topics
    end

    def run
      entries.buffered do |entry|
        Streamy.logger.info "importing #{entry.attributes}"
        yield(entry)
      end
    end

    private

      attr_reader :start_time, :topics

      def entries
        Streamy.event_store.entries.where("event_time >= ?", start_time).order(event_time: :asc).where(topic: topics)
      end
  end
end
