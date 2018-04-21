require "hutch"
require "streamy/workers/rabbit/requeue_on_all_failures"
require "streamy/workers/rabbit/abort_on_all_failures"

module Streamy
  module Workers
    class RabbitWorker
      def initialize(uri:)
        Hutch::Config[:log_level] = Rails.configuration.log_level
        Hutch::Config[:uri] = uri
        Hutch::Config[:enable_http_api_use] = false
        Hutch::Config[:error_acknowledgements] << Rabbit::RequeueOnAllFailures.new
        Hutch::Config[:error_acknowledgements] << Rabbit::AbortOnAllFailures.new
      end

      def run
        Hutch::CLI.new.run([])
      end
    end
  end
end
