require "hutch"

module Streamy
  module Workers
    module Rabbit
      class RequeueOnAllFailures < Hutch::Acknowledgements::Base
        include Hutch::Logging

        def handle(delivery_info, properties, broker, exception)
          broker.requeue(delivery_info.delivery_tag)
          logger.debug "[*] requeued message(#{properties.message_id || '-'})"

          false
        end
      end
    end
  end
end
