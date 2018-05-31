namespace :streamy do
  namespace :worker do
    desc "Start consuming events"
    task :run, [:topic] => [:environment] do |_task, args|
      Streamy.worker.run(args.topic)
    end
  end
end
