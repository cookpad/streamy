namespace :streamy do
  namespace :consumer do
    desc "Start consuming"
    task :run do
      if Rails.application.secrets.rabbitmq_uri.blank?
        raise "Missing `rabbitmq_uri` for '#{Rails.env}' environment, set this value in `config/secrets.yml`"
      end

      Hutch::Config[:uri] = Rails.application.secrets.rabbitmq_uri
      Hutch::Config[:enable_http_api_use] = false
      Hutch::Config[:error_acknowledgements] << Streamy::RabbitMq::Acknowledgements::RequeueOnAllFailures.new
      Hutch::Config[:error_acknowledgements] << Streamy::RabbitMq::Acknowledgements::AbortOnAllFailures.new

      cli = Hutch::CLI.new
      cli.run([])
    end
  end
end
