# Streamy

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'streamy'
```


## Usage


### Broadcasting events

Add this to config/initializer/event_store.rb

```ruby
Streamy.message_bus = Streamy::MessageBuses::FluentMessageBus.new("td.global")
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
# config/streamy_consumer_properties.yml
development: &defaults
  streamName: global-domain-events-staging
  applicationName: global-name-of-app-development
  AWSCredentialsProvider: DefaultAWSCredentialsProviderChain

test:
  <<: *defaults

staging:
  <<: *defaults
  applicationName: global-name-of-app-staging

production:
  <<: *defaults
  streamName: global-domain-events
  applicationName: global-name-of-app
```

Add an event handler:

```ruby
module EventHandlers
  class ReceivedPayment < Streamy::EventHandler
    def process
      PaymentCounter.increment(body[:amount])
    end
  end
end
```

Start the consumer:

```bash
JAVA_HOME=/usr bin/rake streamy:consumer:run
```

### Replaying events

Add this to config/initializer/event_store.rb

```ruby
Streamy.event_store = Streamy::EventStores::CopyBufferedRedshiftStore.new(Rails.configuration.x.event_store)
```

Run the replayer:

```ruby
Streamy::Replayer.new(from: "2017-01-01", topics: %w(payments)).run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/balvig/streamy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

