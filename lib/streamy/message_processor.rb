module Streamy
	class MessageProcessor
		def self.process(message)
			new(message).process
		end

		def initialize(message)
			@message = message
		end

		def process
			ActiveRecord::Base.transaction do
				handler.new(attributes).process
			end
		end

		private

			attr_reader :message

			def handler
				handler_class_name.safe_constantize || raise("No event handler found for #{handler_class_name}")
			end

			def handler_class_name
				"EventHandlers::#{message.type.camelize}"
			end

			def attributes
				{
					body: body,
					event_time: message.event_time
				}
			end

			def body
				(message.body || {}).with_indifferent_access
			end
	end
end
