require "hutch"

module Streamy
  module MessageBuses
    class RabbitMessageBus::Aborter < Hutch::Acknowledgements::Base
      def handle(*)
        puts "[x] abort consumer"

        exit
      end
    end
  end
end
