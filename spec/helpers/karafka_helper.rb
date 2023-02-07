# def setup_karafka
#   # If the spec  is in pro, run in pro mode
#   become_pro! if pro
#
#   Karafka::App.setup do |config|
#     # Use some decent defaults
#     caller_id = [caller_locations(1..1).first.path.split('/').last, SecureRandom.hex(6)].join('-')
#
#     config.kafka = {
#       'bootstrap.servers': '127.0.0.1:9092',
#       'statistics.interval.ms': 100,
#       # We need to send this often as in specs we do time sensitive things and we may be kicked
#       # out of the consumer group if it is not delivered fast enough
#       'heartbeat.interval.ms': 1_000,
#       'queue.buffering.max.ms': 5
#     }
#     config.client_id = caller_id
#     config.pause_timeout = 1
#     config.pause_max_timeout = 1
#     config.pause_with_exponential_backoff = false
#     config.max_wait_time = 500
#     config.shutdown_timeout = 30_000
#
#     # Allows to overwrite any option we're interested in
#     yield(config) if block_given?
#
#     # Configure producer once everything else has been configured
#     config.producer = ::WaterDrop::Producer.new do |producer_config|
#       producer_config.kafka = Karafka::Setup::AttributesMap.producer(config.kafka.dup)
#       producer_config.logger = config.logger
#       # We need to wait a lot sometimes because we create a lot of new topics and this can take
#       # time
#       producer_config.max_wait_timeout = 120 # 2 minutes
#     end
#   end
#
#   Karafka.logger.level = 'debug'
#
#   # We turn on all the instrumentation just to make sure it works also in the integration specs
#   Karafka.monitor.subscribe(Karafka::Instrumentation::LoggerListener.new)
#   Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)
#
#   # We turn on also WaterDrop instrumentation the same way and for the same reasons as above
#   listener = ::WaterDrop::Instrumentation::LoggerListener.new(Karafka.logger)
#   Karafka.producer.monitor.subscribe(listener)
# end
