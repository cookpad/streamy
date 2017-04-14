module Streamy
  module EventStores
    module Redshift
      class Entry < ActiveRecord::Base
        self.inheritance_column = :_type_disabled
        self.primary_key = :key

        def self.find_each(&block)
          RedshiftConnector.foreach(query: all.to_sql, &block)
        end
      end
    end
  end
end
