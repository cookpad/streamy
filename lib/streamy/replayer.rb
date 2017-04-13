module Streamy
  class Replayer
    def initialize(start_time: nil, topics: [])
      @start_time = start_time
      @topics = topics
    end

    def run
      Streamy.data_store.entries.where("event_time >= ?", start_time, topic: topics).find_each do
        Streamy.logger.info "importing #{entry}"
        yield(entry)
      end
    end

    private

      attr_reader :start_time, :topics
  end
end
