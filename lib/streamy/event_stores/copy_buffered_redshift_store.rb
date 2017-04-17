require "streamy/event_stores/redshift/entry"
require "streamy/event_stores/redshift/importer"

module Streamy
  module EventStores
    class CopyBufferedRedshiftStore
      delegate :connection, to: :data_source # gives us raw access to redshift for now

      def initialize(redshift:, s3:)
        @redshift = redshift
        @s3 = s3
        configure_redshift
        configure_buffered_redshift
      end

      def entries
        data_source.all
      end

      def import(&block)
        importer.import(&block)
      end

      private

        attr_reader :redshift, :s3

        def data_source
          Redshift::Entry
        end

        def configure_redshift
          data_source.establish_connection redshift[:db]
          data_source.table_name = "#{redshift[:schema]}.#{redshift[:table]}"
        end

        def configure_buffered_redshift
          RedshiftConnector.logger = Streamy.logger
          RedshiftConnector::Exporter.default_data_source = data_source
          RedshiftConnector::S3Bucket.add reader_config[:bucket], reader_config
        end

        def importer
          Redshift::Importer.new(importer_config)
        end

        def reader_config
          {
            prefix: s3[:read_folder],
            iam_role: s3[:iam_role],
            region: s3[:region],
            bucket: s3[:bucket]
          }
        end

        def importer_config
          {
            folder: s3[:write_folder],
            iam_role: s3[:iam_role],
            region: s3[:region],
            bucket: s3[:bucket]
          }
        end
    end
  end
end
