# Streamy

[![Build Status](https://circleci.com/gh/cookpad/streamy/tree/master.svg?style=svg)](https://circleci.com/gh/cookpad/streamy/tree/master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'streamy'
```


## Usage

### Broadcasting events

Add this to config/initializer/streamy.rb

```ruby
require "streamy/message_buses/rabbit_message_bus"
Streamy.message_bus = Streamy::MessageBuses::RabbitMessageBus.new(
  uri: "amqp://..."
)
```

or if using Kafka

```ruby
require "streamy/message_buses/kafka_message_bus"
Streamy.message_bus = Streamy::MessageBuses::KafkaMessageBus.new(
    client_id: "streamy",
    seed_brokers: "broker.remote:9092",
    ssl_ca_certs_from_system: true,
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

#### Event Priority

When using the Kafka message bus you can choose a priority for your events. This is done by overriding the `priority` method on your event.

The 4 available priorities are:

* `:low` - The event will be sent to Kafka by a background thread, events are buffered until `delivery_threshold` messages are waiting or until `delivery_interval` seconds have passed since the last delivery. Calling publish on a low priority event is non blocking, and no errors should be thrown, unless the buffer is full.
* `:standard` - The event will be sent to Kafka by a background thread, but the thread is signaled to send any buffered events as soon as possible. The call to publish is non blocking, and should not throw errors, unless the buffer is full.
* `:essential` - The event will be sent to Kafka immediately. The call to publish is blocking, and may throw errors.
* `:manual` - The event will be queued to send to Kafka, but no events are sent until `Streamy.deliver_events` is called. This allows manual control of event batching, when creating many events, e.g. in batch jobs. The call to `Streamy.deliver_events` is blocking and may throw errors.

#### Shutdown

When using Kafka, if any `:low` or `:standard` priority events are published you should call `Streamy.shutdown` before your process exits to avoid losing any events.

If you are using puma, you should add this to your `puma.rb`

```
on_worker_shutdown do
  Streamy.shutdown
end
```

Or with unicorn:

```
after_fork do
  at_exit { Streamy.shutdown }
end
```

### Consuming events

Configure the worker:

```ruby
# config/streamy.rb
Streamy.worker = Streamy::Workers::RabbitWorker.new(
  uri: "amqp://..."
)
```

For built-in deduplication of events:

```ruby
# config/streamy.rb
Streamy.cache = Rails.cache
```

Add consumer(s):

```ruby
# app/consumers/event_consumer.rb
class EventConsumer
  include Streamy::Consumer

  # Specify a topic to consume
  consume "payments.#"
end
```

Add event handler(s):

```ruby
module EventHandlers
  class ReceivedPayment < Streamy::EventHandler
    def process
      PaymentCounter.increment(body[:amount])
    end
  end
end
```

Start consuming:

```bash
bin/rake streamy:worker:run
```

### Consuming replayed events

Use `replay` instead of `consume`:

```ruby
class EventConsumer
  include Streamy::Consumer

  replay "payments.#"
end
```

This will create two queues:

```ruby
event_consumer # binds to `payments.#`, accumulates realtime events but doesn't process
event_consumer_replay # binds to `replay.event_consumer.payments.#`, processes replay events
```

Once caught up, switch back to `consume` and optionally specify a
`start_from` timestamp to filter out any realtime events that may
have already been replayed:

```ruby
class EventConsumer
  include Streamy::Consumer

  start_from 1525058571 # last event in replay queue
  consume "payments.#"
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

