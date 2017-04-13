module Streamy
  module EventStores
    class CopyBufferedRedshiftEventStore
      def initializer(redshift:, s3:)
        @redshift = redshift
        @s3 = s3
        configure_redshift
        configure_buffered_redshift
      end

      def entries
        Redshift::Entry.all
      end

      def import(&block)
        importer.import(&block)
      end

      private

        attr_reader :redshift, :s3

        def configure_redshift
          #Redshift::Entry.database = redshift[:schema]
          Redshift::Entry.table_name = redshift[:table]
        end

        def configure_buffered_redshift
          RedshiftConnector.logger = NullLogger.new
          RedshiftConnector::Exporter.default_data_source = Entry
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
