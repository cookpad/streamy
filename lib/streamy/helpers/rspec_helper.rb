require "streamy/helpers/have_hash_matcher"
require "avro_turf/messaging"

module Streamy
  module Helpers
    module RspecHelper
      def expect_event(topic: kind_of(String), key: kind_of(String), body: kind_of(Hash), type:, event_time: kind_of(String), encoding: "json")
        deliveries = hashify_messages(Streamy.message_bus.deliveries, encoding)

        expect(deliveries).to have_hash(
          topic: topic,
          key: key,
          payload: {
            body: body,
            type: type,
            event_time: event_time
          }
        )
      end

      def expect_avro_event(**options)
        expect_event(**options, encoding: "avro")
      end

      alias expect_published_event expect_event
      alias expect_published_avro_event expect_avro_event

      Streamy.message_bus = MessageBuses::TestMessageBus.new

      RSpec.configure do |config|
        config.include Streamy::Helpers::RspecHelper

        config.before(:each) do
          Streamy.message_bus.deliveries.clear
        end
      end

      private

        def hashify_messages(message_bus_deliveries, encoding_type)
          message_bus_deliveries.map do |message|
            message_hash = message.dup
            message_hash[:payload] = parse_message(message_hash[:payload], encoding_type)
            message_hash
          end
        end

        def parse_message(message_payload, encoding_type)
          if encoding_type == "avro"
            avro.decode(message_payload).deep_symbolize_keys
          else
            JSON.parse(message_payload).deep_symbolize_keys
          end
        end

        def avro
          AvroTurf::Messaging.new(
            registry_url: Streamy.configuration.avro_schema_registry_url,
            schemas_path: Streamy.configuration.avro_schemas_path
          )
        end
    end
  end
end
