module Streamy
  class Railtie < Rails::Railtie
    rake_tasks do
      load "streamy/railties/worker.rake"
    end
  end
end
