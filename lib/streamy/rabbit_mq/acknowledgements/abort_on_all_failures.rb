require "hutch"

module Streamy
  module RabbitMq
    module Acknowledgements
      class AbortOnAllFailures < Hutch::Acknowledgements::Base
        include Hutch::Logging

        def handle(*)
          logger.debug "[x] abort consumer"

          exit
        end
      end
    end
  end
end
