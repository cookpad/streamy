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
Streamy.message_bus = Streamy::MessageBuses::RabbitMessageBus.new(
  uri: "amqp://..."
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

