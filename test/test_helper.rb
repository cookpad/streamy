$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "streamy"
require "minitest/autorun"
require "mocha/mini_test"
require "sqlite3"

dummy_configuration = {
  redshift: {
    schema: "streamy",
    table: "domain_events",
    db: {
      adapter:  "sqlite3",
      database: "streamy"
    },
  },
  s3: {}
}

Streamy.event_store = Streamy::EventStores::CopyBufferedRedshiftStore.new(dummy_configuration)

Streamy::EventStores::Redshift::Entry.connection.create_table :"streamy.domain_events", force: true do |t|
  t.string :key
  t.string :topic
  t.string :type
  t.string :body
  t.datetime :event_time
end
