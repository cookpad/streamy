require "multi_json"

module Streamy
  module MessageBuses
    class KinesisMessageBus
      def initialize(stream)
        @stream = stream
      end

      def deliver(key:, topic:, type:, body:, event_time:)
        client.put_record(
          stream_name: stream,
          partition_key: partition_key,
          data: MultiJson.dump(
            key: key,
            topic: topic,
            type: type,
            body: body,
            event_time: event_time
          )
        )
      end

      private

        attr_reader :stream

        def client
          @_client ||= Aws::Kinesis::Client.new(config)
        end

        def config
          {
            region: "us-east-1"
          }
        end

        def partition_key
          "snsr-#{rand(1_000).to_s.rjust(4,'0')}" # not sure what is up with this https://github.com/awslabs/amazon-kinesis-client-ruby/blob/master/samples/sample_kcl_producer.rb#L80
        end
    end
  end
end
