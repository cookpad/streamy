module Streamy
  module EventStores
    module Redshift
      class Connection < ActiveRecord::Base
        establish_connection :"#{Rails.env}_redshift"
      end
    end
  end
end
