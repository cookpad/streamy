module Streamy
  Message = Struct.new(:key, :topic, :type, :body, :event_time) do
    def initialize(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end
