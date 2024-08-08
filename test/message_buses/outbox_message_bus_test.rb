require "test_helper"
require "waterdrop"
require "streamy/message_buses/outbox_message_bus"

module Streamy
  class OutboxMessageBusTest < Minitest::Test
    attr_reader :bus

    def setup
      @model = mock("outbox_model")
      @bus = MessageBuses::OutboxMessageBus.new(model: @model)
    end

    def example_delivery(priority)
      bus.deliver(
        payload: payload.to_s,
        key: "prk-sg-001",
        topic: "charcuterie",
        priority: priority
      )
    end

    def payload
      {
        type: "sausage",
        body: { meat: "pork", herbs: "sage" },
        event_time: "2018"
      }
    end

    def expected_event(key: "prk-sg-001")
      {
        payload: {
          type: "sausage",
          body: {
            meat: "pork",
            herbs: "sage"
          },
          event_time: "2018"
        }.to_s,
        key: key,
        topic: "charcuterie"
      }
    end

    def test_standard_priority_deliver
      @model.expects(:create).with(expected_event)
      example_delivery(:standard)
    end

    def test_low_priority_deliver
      @model.expects(:create).with(expected_event)
      example_delivery(:low)
    end

    def test_essential_priority_deliver
      @model.expects(:create).with(expected_event)
      example_delivery(:essential)
    end

    def test_all_priority_delivery
      @model.expects(:create).with(expected_event)
      example_delivery(:essential)

      @model.expects(:create).with(expected_event)
      example_delivery(:low)

      @model.expects(:create).with(expected_event)
      example_delivery(:standard)
    end

    def test_batch_delivery
      @model.expects(:create).with([
        expected_event(key: "prk-sg-001"),
        expected_event(key: "prk-sg-002"),
        expected_event(key: "prk-sg-003")
      ])

      bus.deliver_many([
        {
          payload: payload.to_s,
          key: "prk-sg-001",
          topic: "charcuterie",
          priority: :standard
        },
        {
          payload: payload.to_s,
          key: "prk-sg-002",
          topic: "charcuterie",
          priority: :standard
        },
        {
          payload: payload.to_s,
          key: "prk-sg-003",
          topic: "charcuterie",
          priority: :standard
        }
      ])
    end
  end
end
