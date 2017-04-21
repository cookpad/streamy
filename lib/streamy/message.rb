module Streamy
  Message = Struct.new(:key, :topic, :type, :body, :event_time) do
    def self.new_from_base64(data)
      json = Base64.decode64(data)
      attributes = JSON.parse(json).symbolize_keys.slice(*members)
      new(attributes)
    end

    def self.new_from_redshift(key, topic, type, body, event_time)
      body = JSON.parse(body || "{}")
      new(key: key, topic: topic, type: type, body: body, event_time: event_time)
    end

    def initialize(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end
