module Streamy
  class KafkaConfiguration < SimpleDelegator
    DEFAULT_SYNC_CONFIG = {
      "request.required.acks": -1, # required_acks: -1 all replicas
      "request.timeout.ms": 5_000, # ack_timeout: 5
      "message.send.max.retries": 30, # max_retries: 30
      "retry.backoff.ms": 2_000, # retry_backoff: 2
      "queue.buffering.max.messages": 10_000, # max_buffer_size : 10_000
      "queue.buffering.max.kbytes": 10_000 # max_buffer_bytesize: 10_000_000
    }.freeze

    DEFAULT_ASYNC_CONFIG = {
      "batch.num.messages": 100, # delivery_threshold: 100
      "queue.buffering.max.ms": 10_000 # delivery_interval: 10
    }.freeze

    def async
      sync.with_defaults(DEFAULT_ASYNC_CONFIG)
    end

    def sync
      with_defaults(DEFAULT_SYNC_CONFIG)
    end
  end
end
