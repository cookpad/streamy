module Streamy
  class KafkaConfiguration < SimpleDelegator
    DEFAULT_PRODUCER_CONFIG = {
      "bootstrap.servers": "localhost:9092",
      "request.required.acks": -1, # all replicas required_acks:
      "request.timeout.ms": 5, # ack_timeout
      "message.send.max.retries": 30, # max_retries
      "retry.backoff.ms": 2, # retry_backoff
      "queue.buffering.max.messages": 10_000, # max_buffer_size
      "queue.buffering.max.kbytes": 10_000 # max_buffer_bytesize: 10_000_000
    }.freeze

    DEFAULT_ASYNC_CONFIG = {
      # max_queue_size: 5_000,
      # delivery_threshold: 100,
      # delivery_interval: 10
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

      self.with_defaults(DEFAULT_PRODUCER_CONFIG)
    end

    private

      def producer_configs
        except(*SUPPORTED_CLIENT_CONFIG_KEYS)
      end
  end
end
