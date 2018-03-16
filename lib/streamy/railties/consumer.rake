namespace :streamy do
  namespace :consumer do
    desc "Start consuming"
    task run: :environment do
      if Rails.application.secrets.rabbitmq_uri.blank?
        raise "Missing `rabbitmq_uri` for '#{Rails.env}' environment, set this value in `config/secrets.yml`"
      end

      Hutch::Config[:uri] = Rails.application.secrets.rabbitmq_uri
      Hutch::Config[:enable_http_api_use] = false

      cli = Hutch::CLI.new
      cli.run(ARGV)
    end
  end
end
