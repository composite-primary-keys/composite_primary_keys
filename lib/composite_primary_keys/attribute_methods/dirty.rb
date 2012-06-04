module ActiveRecord
  module AttributeMethods
    module Dirty
      def write_attribute(attr, value)
        # CPK
        if attr.kind_of?(Array)
          # A *composite* attribute can't be marked as changed! So do nothing now.
          # We will come back in here with an *individual* attribute when Write#write_attribute looks through the individual attributes comprising this composite key:
          # [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
        else
          attr = attr.to_s

          # The attribute already has an unsaved change.
          if attribute_changed?(attr)
            old = @changed_attributes[attr]
            @changed_attributes.delete(attr) unless field_changed?(attr, old, value)
          else
            old = clone_attribute_value(:read_attribute, attr)
            # Save Time objects as TimeWithZone if time_zone_aware_attributes == true
            old = old.in_time_zone if clone_with_time_zone_conversion_attribute?(attr, old)
            @changed_attributes[attr] = old if field_changed?(attr, old, value)
          end
        end

        # Carry on.
        super(attr, value)
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[]= :write_attribute
  public :[]=
end
