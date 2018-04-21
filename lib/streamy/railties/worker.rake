namespace :streamy do
  namespace :worker do
    desc "Start consuming events"
    task run: :environment do
      Streamy.worker.run
    end
  end
end
