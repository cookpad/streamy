require "active_support/core_ext/hash/indifferent_access"
require "ostruct"

module Streamy
  class EventHandler
    def self.run(**args)
      new(**args).run
    end

    def initialize(params)
      @params = params.with_indifferent_access
    end

    def run
      raise "Not implemented"
    end
    alias :process :run

    private

      attr_reader :params
      alias :attributes :params

      def event_time
        params[:event_time]
      end

      def body
        OpenStruct.new(params[:body])
      end
  end
end
