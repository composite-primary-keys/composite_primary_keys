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

          save_changed_attribute(attr, value)
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
