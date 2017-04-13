module Streamy
  module EventStores
    module Redshift
      class Entry < ActiveRecord::Base
        establish_connection :"#{Rails.env}_redshift"
        self.inheritance_column = :_type_disabled

        def self.find_each(&block)
          RedshiftConnector.foreach(query: all.to_sql, &block)
        end
      end
    end
  end
end
