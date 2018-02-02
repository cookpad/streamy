# Streamy

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
       "payments"
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

Configure the consumer:

```yaml
# config/rabbit_mq.yml
enable_http_api_use: false
uri: amqp://...
```

Add consumer(s):

```ruby
# app/consumers/event_consumer.rb
class EventConsumer
  include Streamy::Consumer
end

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
bin/rake streamy:consumer:run
```

### Replaying events

- Use global-events to replay events on a replay queue
- Once caught up, switch to main (paused) queue

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

