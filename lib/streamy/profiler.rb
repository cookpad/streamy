module Streamy
  class Profiler
    def self.profile(name, &block)
      new(name, block).profile
    end

    def initialize(name, block)
      @name = name
      @block = block
    end

    def profile
      time = run_benchmark
      logger.info "_#{name} took #{time.round(2)} seconds_"
    end

    private

      attr_reader :name, :block

      def run_benchmark
        Benchmark.realtime(&block)
      end

      def logger
        @_logger ||= SimpleLogger.new
      end
  end
end
