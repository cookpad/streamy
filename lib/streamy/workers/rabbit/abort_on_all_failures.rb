require "hutch"

module Streamy
  module Workers
    module Rabbit
      class AbortOnAllFailures < Hutch::Acknowledgements::Base
        include Hutch::Logging

        def handle(delivery_info, properties, broker, ex)
          logger.error ex
          logger.error "[x] aborting consumer"

          exit
        end
      end
    end
  end
end
