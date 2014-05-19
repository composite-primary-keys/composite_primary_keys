module ActiveRecord
  module Core

    def init_internals_with_cpk
      init_internals_without_cpk
      # Remove cpk array from attributes, fixes to_json
      @attributes.delete(self.class.primary_key) if self.composite?
    end
    alias_method_chain :init_internals, :cpk
    
    def initialize_dup(other) # :nodoc:
      cloned_attributes = other.clone_attributes(:read_attribute_before_type_cast)
      self.class.initialize_attributes(cloned_attributes, :serialized => false)

      @attributes = cloned_attributes

      # CPK
      #@attributes[self.class.primary_key] = nil
      Array(self.class.primary_key).each {|key| @attributes[key] = nil}

      run_callbacks(:initialize) unless _initialize_callbacks.empty?

      @aggregation_cache = {}
      @association_cache = {}
      @attributes_cache  = {}

      @new_record  = true

      super
    end
  end
end
