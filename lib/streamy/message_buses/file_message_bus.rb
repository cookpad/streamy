module Streamy
  module MessageBuses
    class FileMessageBus
      def initialize(file_path)
        @file_path = file_path
      end

      def deliver(data)
        write_to_file convert_to_redshift_json(data)
      end

      private

        attr_reader :file_path

        def write_to_file(data)
          File.open(file_path, "a") do |file|
            file.write(data)
          end
        end

        def convert_to_redshift_json(data)
          data.merge(timestamp: Time.current).to_json
        end
    end
  end
end
