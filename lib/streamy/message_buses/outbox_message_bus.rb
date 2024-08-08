require "streamy/kafka_configuration"
require "waterdrop"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/json"

module Streamy
  module MessageBuses
    class OutboxMessageBus < MessageBus
      def initialize(config)
        @model = config[:model]
      end

      def deliver(key:, topic:, payload:, priority:)
        @model.create(key: key, topic: topic, payload: payload)
      end

      def deliver_many(messages)
        @model.create(messages.map { |message| message.except(:priority) })
      end
    end
  end
end
