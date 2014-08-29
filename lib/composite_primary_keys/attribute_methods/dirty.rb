module ActiveRecord
  module AttributeMethods
    module Dirty
      def write_attribute(attr, value)
        # CPK
        if attr.kind_of?(Array)
          # A *composite* attribute can't be marked as changed! So do nothing now.
          # We will come back in here with an *individual* attribute when Write#write_attribute looks through the individual attributes comprising this composite key:
          value = [nil] * attr.length if value.nil?
          [attr, value].transpose.map {|name,val| write_attribute(name, val)}
        else
          attr = attr.to_s

          old_value = old_attribute_value(attr)

          result = super
          store_original_raw_attribute(attr)
          save_changed_attribute(attr, old_value)
          result
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[]= :write_attribute
  public :[]=
end
