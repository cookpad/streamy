module Streamy
  module EventStores
    class CopyBufferedRedshiftEventStore
      def initializer(redshift:, s3:)
        @redshift = redshift
        @s3 = s3
      end

      def find(query)
        # currently raw SQL
        reader.read(query)
      end

      def find_each(conditions = {})
        query = Redshift::Query.new(redshift.merge(conditions)).to_sql

        reader.buffered_read(query) do |result|
          yield(result)
        end
      end

      def capture
        Streamy.message_bus = FileMessageBus.new(file_path)

        yield

        writer.upload(file_path)
        FileUtils.rm(file_path)
      end

      private

        attr_reader :redshift, :s3

        def file_path
          Pathname.new(Dir.tmpdir).join("domain_events_export.json.gz")
        end

        def reader
          @_reader ||= Redshift::BufferedReader.new(reader_config)
        end

        def writer
          @_writer ||= Redshift::BufferedWriter.new(writer_config)
        end

        def reader_config
          {
            prefix: s3[:read_folder],
            iam_role: s3[:iam_role],
            region: s3[:region],
            bucket: s3[:bucket]
          }
        end

        def writer_config
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
