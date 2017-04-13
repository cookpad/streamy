module Streamy
  module EventStores
    module Redshift
      class Query
        def initialize(schema:, table:, start_time:, topics: [])
          @from = from
          @topics = topics
        end

        def to_sql
          <<~SQL
          SELECT key, topic, type, body, event_time
          FROM #{schema}.#{table}
          #{conditions}
          ORDER BY event_time
          SQL
        end

        private

          attr_reader :schema, :table, :start_time, :topics

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
            if start_time
              "AND event_time >= '#{start_time}'"
            end
          end
      end
    end
  end
end
