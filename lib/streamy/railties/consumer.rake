namespace :streamy do
  namespace :consumer do
    desc "Start consuming"
    task :run do
      system "bundle exec hutch --config config/rabbit_mq.yml"
    end
  end
end
