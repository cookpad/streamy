module Streamy
  module EventStores
    module Redshift
      class Importer
        def initialize(folder:, file_name:, region:, bucket:)
          @folder = folder
          @file_name = file_name
          @region = region
          @bucket = bucket
        end

        def import
          remove_file
          pipe_messages_to_file
          yield
          gzip_file
          upload_file
          remove_file
        end

        private

          attr_accessor :folder, :file_name, :region, :bucket

          def pipe_messages_to_file
            Streamy.message_bus = MessageBuses::FileMessageBus.new(file_path)
          end

          def gzip_file
            `gzip #{file_path}`
          end

          def upload_file
            Streamy.logger.info "Uploading to #{remote_path}"
            file_store.upload_file(gzip_file_path)
          end

          def remove_file
            FileUtils.rm_f(gzip_file_path)
          end

          def file_path
            Pathname.new(Dir.home).join(file_name).to_s
          end

          def gzip_file_path
            file_path + ".gz"
          end

          def file_store
            Aws::S3::Resource.
              new(region: region).
              bucket(bucket).
              object(remote_path)
          end

          def remote_path
            "#{folder}/#{file_name}"
          end
      end
    end
  end
end
