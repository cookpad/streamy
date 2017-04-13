module Streamy
  module EventStores
    module Redshift
      class BufferedWriter
        def initialize(config)
          @config = config
        end

        def upload(local_file)
          file_store.
            object(remote_path(local_file)).
            upload_file(local_file)
        end

        private

          attr_accessor :config, :local_file

          def file_store
            Aws::S3::Resource.new(region: config[:region]).bucket(config[:bucket])
          end

          def remote_path(local_file)
            config[:folder] + "/" + File.basename(local_file)
          end
      end
    end
  end
end
