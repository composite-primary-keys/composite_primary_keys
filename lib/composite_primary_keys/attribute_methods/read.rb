module ActiveRecord
  module AttributeMethods
    module Read
      rails_read_attribute = instance_method(:read_attribute)
      define_method(:read_attribute) do |attr_name|
        if attr_name.kind_of?(Array)
          attr_name.map {|name| read_attribute(name)}.to_composite_keys
        else
          rails_read_attribute.bind(self).(attr_name)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[] :read_attribute
end
