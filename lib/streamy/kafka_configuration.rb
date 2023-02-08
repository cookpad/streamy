module Streamy
  class KafkaConfiguration < SimpleDelegator
    DEFAULT_SYNC_CONFIG = {
      "bootstrap.servers": "localhost:9092", # ?
      "request.required.acks": -1, # required_acks: -1 all replicas
      "request.timeout.ms": 5_000, # ack_timeout: 5
      "message.send.max.retries": 30, # max_retries: 30
      "retry.backoff.ms": 2_000, # retry_backoff: 2
      "queue.buffering.max.messages": 10_000, # max_buffer_size : 10_000
      "queue.buffering.max.kbytes": 10_000 # max_buffer_bytesize: 10_000_000
    }.freeze

    DEFAULT_ASYNC_CONFIG = {
      # "queue.buffering.max.messages": 5_000, # max_queue_size: 5_000
      "batch.num.messages": 100, # delivery_threshold: 100
      "queue.buffering.max.ms": 10_000 # delivery_interval: 10
    }.freeze

    DEFAULT_CLIENT_CONFIG = {
    }.freeze

    SUPPORTED_CLIENT_CONFIG_KEYS = %i(logger max_payload_size max_wait_timeout wait_timeout deliver).freeze

    def async
      # slice(*DEFAULT_ASYNC_CONFIG.keys).with_defaults(DEFAULT_ASYNC_CONFIG).merge(producer)

      sync.with_defaults(DEFAULT_ASYNC_CONFIG)
    end

    def sync
      # slice(*DEFAULT_PRODUCER_CONFIG.keys).with_defaults(DEFAULT_PRODUCER_CONFIG)

      self.with_defaults(DEFAULT_SYNC_CONFIG)
    end
  end
end
