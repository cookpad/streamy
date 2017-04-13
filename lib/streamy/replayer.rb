module Streamy
  class Replayer
    def initialize(start_time: nil, topics: [])
      @start_time = start_time
      @topics = topics
    end

    def run
      Streamy.data_store.find_each(start_time: from, topics: topics) do |row|
        Streamy.logger.info "importing #{row}"
        yield(row)
      end
    end

    private

      attr_reader :from, :topics
  end
end
