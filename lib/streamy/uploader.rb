module Streamy
  class Uploader
    cattr_accessor :config

    def self.upload(*args)
      new(*args).upload
    end

    def initialize(local_file)
      @local_file = local_file
    end

    def upload
      Aws::S3::Resource.
        new(region: config[:region]).
        bucket(config[:bucket]).
        object(remote_path).
        upload_file(local_file)
    end

    private

      attr_accessor :local_file

      def remote_path
        "#{config[:folder]}/#{file_path}"
      end

      def file_path
        File.basename(local_file)
      end
  end
end
