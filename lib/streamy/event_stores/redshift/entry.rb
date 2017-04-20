module Streamy
  module EventStores
    module Redshift
      class Entry < ActiveRecord::Base
        self.inheritance_column = :_type_disabled
        self.primary_key = :key

        def self.buffered(&block)
          schema, table = table_name.split(".")
          RedshiftConnector.foreach(query: all.to_sql, enable_sort: true, schema: schema, table: table, &block)
        end
      end
    end
  end
end
