module Streamy
  class Exporter
    def self.capture_events_on_s3(file_name, &block)
      Profiler.profile("Capturing to S3") do
        file_path = Pathname.new(Dir.tmpdir).join("domain_events_#{file_name}.json.gz")
        Streamy.message_bus = FileMessageBus.new(file_path)

        yield

        Uploader.upload(file_path)
        FileUtils.rm(file_path)
      end
    end
  end
end
