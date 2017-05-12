# Streamy

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/streamy`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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


Add a properties file for each environment:

```ruby
# kcl/consumer.development.properties
executableName = consumer.rb
streamName = global-reports-staging-001
applicationName = global_reports_staging
AWSCredentialsProvider = DefaultAWSCredentialsProviderChain
processingLanguage = ruby
initialPositionInStream = TRIM_HORIZON
```

Add this to config/initializer/event_store.rb

```ruby
Streamy.event_store = Streamy::EventStores::CopyBufferedRedshiftStore.new(Rails.configuration.x.event_store)
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/balvig/streamy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

