module Streamy
  class RedshiftEventReplayer
    def initialize(from: nil, topics: [])
      @from = from
      @topics = topics
    end

    def run
      read_past_events do |event|
        replay(*event)
      end
    end

    private

      attr_reader :from, :topics

      def read_past_events(&block)
        data_store.buffered_read(conditions) do |result|
          yield(result)
        end
      end

      def data_store
        Streamy.data_store
      end

      def replay(*row)
        logger.info "importing #{row}"
        message = Message.new_from_redshift(*row)
        message.log_and_process
      end

      def conditions
        <<~SQL
        WHERE topic IN (#{subscribed_topics_sql})
        #{event_time_range_sql}
        SQL
      end

      def subscribed_topics_sql
        topics.map { |topic| "'#{topic}'" }.join(",")
      end

      def event_time_range_sql
        if from
          "AND event_time >= '#{from}'"
        end
      end

      def logger
        @_logger ||= SimpleLogger.new(STDOUT)
      end
  end
end
