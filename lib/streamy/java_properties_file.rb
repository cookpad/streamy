require "tempfile"

class JavaPropertiesFile < Tempfile
  def initialize(name, default_properties = {})
    super [name, ".properties"]
    @name = name
    @default_properties = default_properties
    write_properties
  end

  private

    attr_reader :name, :default_properties

    def properties
      default_properties.merge(rails_properties)
    end

    def rails_properties
      Rails.application.config_for("streamy_#{name}_properties")
    rescue
      {}
    end

    def write_properties
      properties.each do |key, value|
        puts("#{key} = #{value}")
      end
      flush
    end
end
