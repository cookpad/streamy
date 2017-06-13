require "aws/kclrb"

module Streamy
  class Consumer < Aws::KCLrb::RecordProcessorBase
    def init_processor(shard_id)
      logger.info "Initializing shard: #{shard_id}"
    end

    def process_records(records, checkpointer)
      logger.debug "Processing #{records.size} record(s)"
      records.each do |record|
        begin
          process(record)
        rescue => e
          logger.error "#{e}: Failed to process record '#{record}'"
          pause
        end
      end

      if last_sequence_number
        add_checkpoint(checkpointer)
      end
    end

    def shutdown(checkpointer, reason)
      if reason == "TERMINATE"
        logger.info "Was told to terminate, will attempt to checkpoint"
        add_checkpoint(checkpointer)
      else
        logger.info "Shutting down due to failover. Will not checkpoint."
      end
    end

    private

      attr_accessor :last_sequence_number, :paused

      def process(record)
        if paused
          logger.error "Currently paused, ignoring record: " + record["sequenceNumber"]
        else
          message = Streamy::Message.new_from_base64(record["data"])
          Streamy.message_processor.process(message)
          self.last_sequence_number = record["sequenceNumber"]
        end
      end

      def add_checkpoint(checkpointer)
        logger.debug "Adding checkpoint: #{sequence_number_log}"
        begin
          checkpointer.checkpoint(last_sequence_number)
        rescue Aws::KCLrb::CheckpointError => e
          logger.info "Retrying checkpoint #{e}"
          # Here, we simply retry once.
          # More sophisticated retry logic is recommended.
          checkpointer.checkpoint(last_sequence_number)
        end
      end

      def pause
        logger.info "Pausing consumer"
        self.paused = true
      end

      def sequence_number_log
        last_sequence_number || "<no sequence number>"
      end

      # Cannot use STDOUT https://github.com/awslabs/amazon-kinesis-client-ruby/blob/b7a3ed38f282a53b73a5cdde677bc50671ee2ed8/samples/sample_kcl.rb#L24-L27
      def logger
        @_logger ||= Streamy::SimpleLogger.new(STDERR)
      end
  end
end
