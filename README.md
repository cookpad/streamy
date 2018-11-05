# Streamy

[![Build Status](https://circleci.com/gh/cookpad/streamy/tree/master.svg?style=svg)](https://circleci.com/gh/cookpad/streamy/tree/master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "streamy"
```


## Usage

### Broadcasting events

Add this to config/initializer/streamy.rb

```ruby
require "streamy/message_buses/kafka_message_bus"
Streamy.message_bus = Streamy::MessageBuses::KafkaMessageBus.new(
  client_id: "streamy",
  seed_brokers: "broker.remote:9092",
  ssl_ca_certs_from_system: true
)
```

Create an event:

```ruby
module Events
  class ReceivedPayment < Streamy::Event
    def topic
       "payments.transactions"
    end

    def body
      {
        amount: 200
      }
    end

    def event_time
      Time.now
    end
  end
end
```

Publish it:


```ruby
Events::ReceivedPayment.publish
```

---

### Consuming events

We use [karafka](https://github.com/karafka/karafka) to handle the bulk of the consumer logic.

Configure karafka consumer:

```rb
class ApplicationConsumer < Karafka::BaseConsumer
  def consume
    params_batch.each do |message|
      Streamy::MessageProcessor.new(message).run
    end
  end
end
```

Add event handler(s):

```ruby
# app/handlers/received_payment_handler.rb
class ReceivedPaymentHandler
  def initialize(body)
    @body = message
  end

  def process
    PaymentCounter.increment(body[:amount])
  end

  private

    attr_reader :body
end
```

---

## Advanced options

### Event Priority

You can choose a priority for your events. This is done by overriding the `priority` method on your event:

* `:low` - The event will be sent to Kafka by a background thread, events are buffered until `delivery_threshold` messages are waiting or until `delivery_interval` seconds have passed since the last delivery. Calling publish on a low priority event is non blocking, and no errors should be thrown, unless the buffer is full.
* `:standard` - The event will be sent to Kafka by a background thread, but the thread is signaled to send any buffered events as soon as possible. The call to publish is non blocking, and should not throw errors, unless the buffer is full.
* `:essential` - The event will be sent to Kafka immediately. The call to publish is blocking, and may throw errors.
* `:batched` - The event will be queued to send to Kafka, but no events are sent until `max_buffer_size` is reached. This allows efficient event batching, when creating many events, e.g. in batch jobs. When a batch of events is being delivered the call to publish will block, and may throw errors.

### Shutdown

To ensure that all `:low` `:batched` or `:standard` priority events are published `Streamy.shutdown` should be called before your process exits to avoid losing any events.
Streamy automatically adds an `at_exit` hook to initiate this, but if you are doing something unusual you might need to be aware of this.

---


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
