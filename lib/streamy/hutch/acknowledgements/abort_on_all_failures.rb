require "hutch"

module Streamy
  module Hutch
    module Acknowledgements
      class AbortOnAllFailures < ::Hutch::Acknowledgements::Base
        def handle(*)
          puts "[x] abort consumer"

          exit
        end
      end
    end
  end
end
