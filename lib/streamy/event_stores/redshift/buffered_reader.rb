module Streamy
  module EventStores
    module Redshift
      class BufferedReader
        def initialize(config)
          @config = config
          configure_redshift_connector
        end

        def read(query)
          Connection.connection.execute(query).first || {}
        end

        def buffered_read(query, &block)
          RedshiftConnector.foreach(query: query, &block)
        end

        private

          attr_accessor :config

          def configure_redshift_connector
            RedshiftConnector.logger = NullLogger.new
            RedshiftConnector::Exporter.default_data_source = Connection
            RedshiftConnector::S3Bucket.add config[:bucket], config
          end
      end
    end
  end
end
