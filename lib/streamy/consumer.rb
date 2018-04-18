require "hutch"

module Streamy
  module Consumer
    def self.included(base)
      base.include Hutch::Consumer
    end

    def process(message)
      MessageProcessor.new(message).run
    end
  end
end
