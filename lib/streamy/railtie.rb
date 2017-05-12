module Streamy
  class Railtie < Rails::Railtie
    rake_tasks do
      load "streamy/railties/consumer.rake"
    end
  end
end
