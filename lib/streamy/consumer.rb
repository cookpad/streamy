require "hutch"

module Streamy
  module Consumer
    def self.included(base)
      base.include Hutch::Consumer
      Hutch::Logging.logger = Streamy.logger
      base.consume "#{Streamy::DEFAULT_TOPIC_PREFIX}.#"

      configure_hutch
    end

    def process(message)
      MessageProcessor.new(message).run
    end

    def self.configure_hutch
      Hutch::Config.set(
        :error_acknowledgements,
        [
          RabbitMq::Acknowledgements::RequeueOnAllFailures.new,
          RabbitMq::Acknowledgements::AbortOnAllFailures.new
        ]
      )
    end
  end
end
