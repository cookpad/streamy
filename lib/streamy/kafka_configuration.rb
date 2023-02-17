module Streamy
  class KafkaConfiguration < SimpleDelegator
    DEFAULT_SYNC_CONFIG = {
      "request.required.acks": -1,
      "request.timeout.ms": 5_000,
      "message.send.max.retries": 30,
      "retry.backoff.ms": 2_000,
      "queue.buffering.max.messages": 10_000,
      "queue.buffering.max.kbytes": 10_000
    }.freeze

    DEFAULT_ASYNC_CONFIG = {
      "queue.buffering.max.messages": 5_000,
      "batch.num.messages": 100,
      "queue.buffering.max.ms": 10_000
    }.freeze

    def async
      with_defaults(DEFAULT_ASYNC_CONFIG).with_defaults(DEFAULT_SYNC_CONFIG)
    end

    def sync
      with_defaults(DEFAULT_SYNC_CONFIG)
    end
  end
end
