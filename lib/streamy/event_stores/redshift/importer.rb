module Streamy
  module EventStores
    module Redshift
      class Importer
        def initialize(config)
          @config = config
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

          attr_accessor :config

          def pipe_messages_to_file
            Streamy.message_bus = MessageBuses::FileMessageBus.new(file_path)
          end

          def gzip_file
            `gzip #{file_path}`
          end

          def upload_file
            file_store.upload_file(gzip_file_path)
          end

          def remove_file
            FileUtils.rm_f(gzip_file_path)
          end

          def file_path
            Pathname.new(Dir.home).join("domain_events_export.json").to_s
          end

          def gzip_file_path
            file_path + ".gz"
          end

          def file_store
            Aws::S3::Resource.
              new(region: config[:region]).
              bucket(config[:bucket]).
              object(remote_path)
          end

          def remote_path
            config[:folder] + "/" + File.basename(file_path)
          end
      end
    end
  end
end
