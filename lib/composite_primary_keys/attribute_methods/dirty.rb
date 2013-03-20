module ActiveRecord
  module AttributeMethods
    module Dirty
      alias_method :rails_dirty_write_attribute, :write_attribute
      def write_attribute(attr, value)
        # CPK: A *composite* attribute can't be marked as changed! So do nothing now.
        # We will come back in here with an *individual* attribute when Write#write_attribute looks through the individual attributes comprising this composite key:
        # [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
        rails_dirty_write_attribute(attr, value) unless attr.kind_of?(Array)        
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[]= :write_attribute
  public :[]=
end
