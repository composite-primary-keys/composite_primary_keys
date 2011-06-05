module ActiveRecord
  module AttributeMethods
    module Dirty
      def write_attribute(attr, value)
        # CPK
        # attr = attr.to_s
        attr = attr.to_s unless self.composite?

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
