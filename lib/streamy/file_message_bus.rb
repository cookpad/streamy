module Streamy
  class FileMessageBus
    def initialize(file_path)
      @file_path = file_path
    end

    def deliver(data)
      write_to_file convert_to_redshift_json(data)
    end

    private

      attr_reader :file_path, :deliveries

      def write_to_file(data)
        Zlib::GzipWriter.open(file_path) do |gz|
          gz.write(data + "\n")
        end
      end

      def convert_to_redshift_json(data)
        data.merge(timestamp: Time.current).to_json
      end
  end
end
