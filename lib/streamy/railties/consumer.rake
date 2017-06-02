require "open-uri"

KCL_DIR = File.expand_path("../../../kcl", File.dirname(__FILE__))
JAR_DIR = File.join(KCL_DIR, "jars")
directory JAR_DIR

def get_maven_jar_info(group_id, artifact_id, version)
  jar_name = "#{artifact_id}-#{version}.jar"
  jar_url = "http://repo1.maven.org/maven2/#{group_id.gsub(/\./, '/')}/#{artifact_id}/#{version}/#{jar_name}"
  local_jar_file = File.join(JAR_DIR, jar_name)
  [jar_name, jar_url, local_jar_file]
end

def download_maven_jar(group_id, artifact_id, version)
  jar_name, jar_url, local_jar_file = get_maven_jar_info(group_id, artifact_id, version)
  open(jar_url) do |remote_jar|
    open(local_jar_file, 'w') do |local_jar|
      IO.copy_stream(remote_jar, local_jar)
    end
  end
end

MAVEN_PACKAGES = [
  # (group id, artifact id, version),
  ['com.amazonaws', 'amazon-kinesis-client', '1.7.4'],
  ['com.amazonaws', 'aws-java-sdk-dynamodb', '1.11.91'],
  ['com.amazonaws', 'aws-java-sdk-s3', '1.11.91'],
  ['com.amazonaws', 'aws-java-sdk-kms', '1.11.91'],
  ['com.amazonaws', 'aws-java-sdk-core', '1.11.91'],
  ['commons-logging', 'commons-logging', '1.1.3'],
  ['org.apache.httpcomponents', 'httpclient', '4.5.2'],
  ['org.apache.httpcomponents', 'httpcore', '4.4.4'],
  ['commons-codec', 'commons-codec', '1.9'],
  ['com.fasterxml.jackson.core', 'jackson-databind', '2.6.6'],
  ['com.fasterxml.jackson.core', 'jackson-annotations', '2.6.0'],
  ['com.fasterxml.jackson.core', 'jackson-core', '2.6.6'],
  ['com.fasterxml.jackson.dataformat', 'jackson-dataformat-cbor', '2.6.6'],
  ['joda-time', 'joda-time', '2.8.1'],
  ['com.amazonaws', 'aws-java-sdk-kinesis', '1.11.14'],
  ['com.amazonaws', 'aws-java-sdk-cloudwatch', '1.11.14'],
  ['com.google.guava', 'guava', '18.0'],
  ['com.google.protobuf', 'protobuf-java', '2.6.1'],
  ['commons-lang', 'commons-lang', '2.6']
]

namespace :streamy do
  namespace :consumer do
    task :download_jars => [JAR_DIR]

    MAVEN_PACKAGES.each do |jar|
      _, _, local_jar_file = get_maven_jar_info(*jar)
      file local_jar_file do
        puts "Downloading '#{local_jar_file}' from maven..."
        download_maven_jar(*jar)
      end
      task :download_jars => local_jar_file
    end

    task process: :environment do
      consumer = Streamy::Consumer.new
      driver = Aws::KCLrb::KCLProcess.new(consumer)
      driver.run
    end

    desc "Run KCL sample processor"
    task :run => :download_jars do
      puts "Running the Kinesis sample processing application..."
      ENV['PATH'] = "#{ENV['PATH']}:#{KCL_DIR}"
      prepare_properties_file
      sh *kcl_command
    end

    private

      def kcl_command
        %W(
        #{java_path}/bin/java
        -classpath #{classpath}
        com.amazonaws.services.kinesis.multilang.MultiLangDaemon #{properties_file.path}
        )
      end

      def java_path
        ENV["JAVA_HOME"] || fail("JAVA_HOME environment variable not set.")
      end

      def properties_file
        @_properties_file ||= Tempfile.new ["streamy-consumer-config", ".properties"]
      end

      def prepare_properties_file
        consumer_properties.each do |key, value|
          properties_file.puts("#{key} = #{value}")
        end
        properties_file.flush
      end

      def consumer_properties
        Rails.application.config_for(:streamy_consumer_properties).reverse_merge(default_properties)
      end

      def default_properties
        {
          executableName: "bin/rake streamy:consumer:process",
          processingLanguage: "ruby",
          initialPositionInStream: "TRIM_HORIZON",
          AWSCredentialsProvider: "DefaultAWSCredentialsProviderChain"
        }
      end

      def classpath
        dependencies.join(":")
      end

      def dependencies
        FileList["#{JAR_DIR}/*.jar"] + [KCL_DIR]
      end
  end
end
