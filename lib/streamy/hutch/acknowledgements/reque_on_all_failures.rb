require "hutch"

module Streamy
  module Hutch
    module Acknowledgements
      class ResqueOnAllFailures < ::Hutch::Acknowledgements::Base
        def handle(delivery_info, properties, broker, ex)
          broker.requeue(delivery_info.delivery_tag)
          puts "[*] requeued message(#{properties.message_id || '-'})"

          false
        end
      end
    end
  end
end
