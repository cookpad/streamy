module Streamy
  class KafkaConfiguration < SimpleDelegator
    DEFAULT_PRODUCER_CONFIG = {
      required_acks:       -1, # all replicas
      ack_timeout:         5,
      max_retries:         30,
      retry_backoff:       2,
      max_buffer_size:     1000,
      max_buffer_bytesize: 10_000_000
    }.freeze

    DEFAULT_ASYNC_CONFIG = {
      max_queue_size:      1000,
      delivery_threshold:  25,
      delivery_interval:   5
    }.freeze

    DEFAULT_KAFKA_CONFIG = {
      logger: Streamy.logger
    }.freeze

    def async
      slice(*DEFAULT_ASYNC_CONFIG.keys).with_defaults(DEFAULT_ASYNC_CONFIG).merge(producer)
    end

    def producer
      slice(*DEFAULT_PRODUCER_CONFIG.keys).with_defaults(DEFAULT_PRODUCER_CONFIG)
    end

    def kafka
      except(*async.keys).with_defaults(DEFAULT_KAFKA_CONFIG)
    end
  end
end
