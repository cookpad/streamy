require "tempfile"

class JavaPropertiesFile < Tempfile
  def initialize(properties = {})
    super ["", ".properties"]
    @properties = properties
    write_properties
  end

  private

    attr_reader :properties

    def write_properties
      properties.each do |key, value|
        puts("#{key} = #{value}")
      end
      flush
    end
end
