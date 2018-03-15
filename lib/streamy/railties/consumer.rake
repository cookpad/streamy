namespace :streamy do
  namespace :consumer do
    desc "Start consuming"
    task run: :environment do
      if Rails.application.secrets.rabbitmq_uri.blank?
        raise "Missing `rabbitmq_uri` for '#{Rails.env}' environment, set this value in `config/secrets.yml`"
      end

      system(
        {
          "HUTCH_URI" => Rails.application.secrets.rabbitmq_uri,
          "HUTCH_ENABLE_HTTP_API_USE" => "false"
        },
        "bundle exec hutch"
      )
    end
  end
end
