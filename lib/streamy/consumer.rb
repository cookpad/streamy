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
          break
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

      attr_accessor :last_sequence_number

      def process(record)
        message = Streamy::Message.new_from_base64(record["data"])
        Streamy.message_processor.process(message)
        self.last_sequence_number = record["sequenceNumber"]
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

      def sequence_number_log
        last_sequence_number || "<no sequence number>"
      end

      def logger
        @_logger ||= Streamy::SimpleLogger.new Rails.root.join("log", "consumer.log")
      end
  end
end
