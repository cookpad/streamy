require "hutch"

module Streamy
  module MessageBuses
    class RabbitMessageBus::Resquer < Hutch::Acknowledgements::Base
      def handle(delivery_info, properties, broker, ex)
        broker.requeue(delivery_info.delivery_tag)
        puts "[*] requeued message(#{properties.message_id || '-'})"

        false
      end
    end
  end
end
