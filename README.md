# Streamy

[![Build Status](https://circleci.com/gh/cookpad/streamy/tree/master.svg?style=svg)](https://circleci.com/gh/cookpad/streamy/tree/master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "streamy"
```


## Usage

### Broadcasting events

Streamy includes support for two different types of event encoding (JSON and [Avro](https://avro.apache.org/docs/current/spec.html)).

#### Events with JSON encoding

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
  class ReceivedPayment < Streamy::JsonEvent
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

#### Events with Avro encoding

Add this to config/initializer/streamy.rb

```ruby
require "streamy/message_buses/kafka_message_bus"
Streamy.message_bus = Streamy::MessageBuses::KafkaMessageBus.new(
  client_id: "streamy",
  seed_brokers: "broker.remote:9092",
  ssl_ca_certs_from_system: true,
)

Streamy.configure do |config|
  config.avro_schema_registry_url = "http://registry.example.com",
  config.avro_schemas_path = "app/schemas"
end  
```

*Default schemas path is "app/schemas"*
*Schema Registry Url is required for encoding with Avro*

Create an event:

```ruby
module Events
  class ReceivedPayment < Streamy::AvroEvent
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

Create Avro schema (`received_payment.asvc`) for event in schema path above:

```json
{
   "type": "record",
   "name": "received_payment",
   "fields": [
     {
       "name": "type",
       "type": "string"
     },
     {
       "name": "event_time",
       "type": {
         "type": "long",
         "logicalType": "timestamp-micros"
        }
     },
     {
       "name": "body",
       "type": {
         "type": "record",
         "name": "body",
         "fields": [
           {
             "name": "amount",
             "type": ["null", "int"],
             "default": null
           }
         ]
       }
     }
   ]
}

```

Publish event:


```ruby
Events::ReceivedPayment.publish
```

---

### Consuming events

We use [karafka](https://github.com/karafka/karafka) to handle the bulk of the consumer logic. You can also use [karafka/avro](https://github.com/karafka/avro) to consume Avro encoded events.

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
* `:standard` (default) - The event will be sent to Kafka by a background thread, but the thread is signaled to send any buffered events as soon as possible. The call to publish is non blocking, and should not throw errors, unless the buffer is full.
* `:essential` - The event will be sent to Kafka immediately. The call to publish is blocking, and may throw errors.
* `:batched` - The event will be queued to send to Kafka using a synchronous producer, but no events are sent until `batched_message_limit` is reached or the synchronous producer in the specific thread has `deliver_messages` called by another service. This allows efficient event batching, when creating many events, e.g. in batch jobs. When a batch of events is being delivered the call to publish will block, and may throw errors.

This can be set in the config for Streamy. (The default is `1000` messages in a batch). Be aware you should set this below the default `max_buffer_size` of `10_000`, as you will get `Kafka::BufferOverflow` errors and you would not be able to send batched messages. It can be set in the Streamy initializer in your host application as below.

```ruby
  require "streamy/message_buses/kafka_message_bus"
  Streamy.message_bus = Streamy::MessageBuses::KafkaMessageBus.new(
    batched_message_limit: 1000
  )
```

### Shutdown

To ensure that all `:low` `:batched` or `:standard` priority events are published `Streamy.shutdown` should be called before your process exits to avoid losing any events.
Streamy automatically adds an `at_exit` hook to initiate this, but if you are doing something unusual you might need to be aware of this.

## Testing

Streamy provides a few helpers to make testing a breeze:

### RSpec

```ruby
it "does publish an received payment" do
  ReceivedPayment.publish

  expect_event(
    type: "received_payment",
    topic: "payments.transactions",
    body: {
      amount: 200
    }
  )
end
```

### Minitest and TestUnit

```ruby
def test_publish_received_payment
  ReceivedPayment.publish

  assert_event(
    type: "received_payment",
    topic: "payments.transactions",
    body: {
      amount: 200
    }
  )
end
```

---


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
